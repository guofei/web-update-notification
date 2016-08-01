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
  def regist(token)
  end

  def push_to_devise
  end
end
