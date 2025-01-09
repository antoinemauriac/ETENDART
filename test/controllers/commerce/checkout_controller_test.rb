require "test_helper"

class Commerce::CheckoutControllerTest < ActionDispatch::IntegrationTest
  test "should get success" do
    get commerce_checkout_success_url
    assert_response :success
  end

  test "should get cancel" do
    get commerce_checkout_cancel_url
    assert_response :success
  end
end
