require 'aws-sdk'

module Pushable
  # instance methods

  # http://docs.aws.amazon.com/sns/latest/dg/mobile-platform-endpoint.html
  # retrieve the latest device token from the mobile operating system
  # if (the platform endpoint ARN is not stored)
  #   # this is a first-time registration
  #   call create platform endpoint
  #   store the returned platform endpoint ARN
  # endif
  #
  # call get endpoint attributes on the platform endpoint ARN
  #
  # if (while getting the attributes a not-found exception is thrown)
  #   # the platform endpoint was deleted
  #   call create platform endpoint with the latest device token
  #   store the returned platform endpoint ARN
  # else
  #   if (the device token in the endpoint does not match the latest one) or
  #     (get endpoint attributes shows the endpoint as disabled)
  #     call set endpoint attributes to set the latest device token
  #     and then enable the platform endpoint
  #   endif
  # endif
  def regist
    return if device_token.nil?
    create_endpoint if endpoint_arn.nil?
    resp = sns_client.get_endpoint_attributes(endpoint_arn: endpoint_arn)
    if need_update_attributes?(resp, device_token)
      update_attributes(device_token, endpoint_arn)
    end
    enable
  rescue Aws::SNS::Errors::NotFoundException => _
    create_endpoint
    enable
  end

  def push_to_device(json_data)
    sns_client.publish(
      target_arn: endpoint_arn,
      message: json_data,
      message_structure: 'json'
    )
  rescue AWS::SNS::Errors::EndpointDisabled
    disable
  end

  private

  def create_endpoint
    endpoint = get_endpoint(device_token)
    return if endpoint.nil?
    self.endpoint_arn = endpoint
    save
  end

  def get_endpoint(token)
    response = sns_client.create_platform_endpoint(
      platform_application_arn: application_arn, token: token)
    response[:endpoint_arn]
  rescue => e
    result = e.message.match(/Endpoint(.*)already/)
    result[1].strip if result.present?
    nil
  end

  def sns_client
    Aws::SNS::Client.new(
      access_key_id: Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region: Rails.application.secrets.aws_region
    )
  end

  def application_arn
    Rails.application.secrets.aws_application_arn
  end

  def need_update_attributes?(resp, token)
    resp.attributes['Token'] != token ||
      resp.attributes['Enabled'] != 'true'
  end

  def update_attributes(token, endpoint)
    sns_client.set_endpoint_attributes(
      attributes: { Token: token, Enabled: 'true' },
      endpoint_arn: endpoint
    )
  end
end
