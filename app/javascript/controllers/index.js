// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import ActivityFormController from "./activity_form_controller"
application.register("activity-form", ActivityFormController)

import AddressAutocompleteController from "./address_autocomplete_controller"
application.register("address-autocomplete", AddressAutocompleteController)

import EnrollmentFormController from "./enrollment_form_controller"
application.register("enrollment-form", EnrollmentFormController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import HiddenFormsController from "./hidden_forms_controller"
application.register("hidden-forms", HiddenFormsController)

import PresenceSheetController from "./presence_sheet_controller"
application.register("presence-sheet", PresenceSheetController)

import SidebarController from "./sidebar_controller"
application.register("sidebar", SidebarController)

import StudentTableController from "./student_table_controller"
application.register("student-table", StudentTableController)
