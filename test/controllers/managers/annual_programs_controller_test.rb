require "test_helper"

class Managers::AnnualProgramsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get managers_annual_programs_new_url
    assert_response :success
  end

  test "should get create" do
    get managers_annual_programs_create_url
    assert_response :success
  end

  test "should get show" do
    get managers_annual_programs_show_url
    assert_response :success
  end

  test "should get index" do
    get managers_annual_programs_index_url
    assert_response :success
  end
end
