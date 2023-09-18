require "test_helper"

class Managers::ImportAnnualStudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get import" do
    get managers_import_annual_students_import_url
    assert_response :success
  end
end
