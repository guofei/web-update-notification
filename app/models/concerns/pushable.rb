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
  #     call set endpoint attributes to set the latest device token and then enable the platform endpoint
  #   endif
  # endif
  def regist
    create_endpoint if self.endpoint_arn.nil?
    resp = sns_client.get_endpoint_attributes(endpoint_arn: self.endpoint_arn)
    if resp.attributes['Token'] != self.device_token ||
       resp.attributes['Enabled'] != 'true'
      sns_client.set_endpoint_attributes(
        endpoint_arn: self.endpoint_arn,
        attributes: { Token: self.device_token, Enabled: 'true' }
      )
    end
  rescue Aws::SNS::Errors::NotFoundException => _
    create_endpoint
  end

  def push_to_devise
  end

  private

  def create_endpoint
    response = sns_client.create_platform_endpoint(
      platform_application_arn: application_arn,
      token: self.device_token
    )
    self.endpoint_arn = response[:endpoint_arn]
    self.save
  rescue => e
    result = e.message.match(/Endpoint(.*)already/)
    if result.present?
      self.endpoint_arn = result[1].strip
      self.save
    end
  end

  def sns_client
    sns = AWS::SNS.new(
      access_key_id: Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region: Rails.application.secrets.aws_region
    )
    sns.client
  end

  def application_arn
    Rails.application.secrets.aws_application_arn
  end
end
