RSpec::Matchers.define :have_error do |error_code|
  match do |response|
    response.status == status &&
    response.success? == false 
  end

  failure_message do |_actual|
    "expected that '#{response.body}' would match '#{error_code}' code"
  end
end