import os

import pytest
from pathlib import Path

from container_ci_suite.openshift import OpenShiftAPI

test_dir = Path(os.path.abspath(os.path.dirname(__file__)))

VERSION=os.getenv("SINGLE_VERSION")
if not VERSION:
    VERSION="3.1-ubi8"

class TestRailsAppExTemplate:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix="rails-example")
        json_raw_file = self.oc_api.get_raw_url_for_json(
            container="s2i-ruby-container", dir="imagestreams", filename="ruby-rhel.json"
        )
        self.oc_api.import_is(path=json_raw_file, name="ruby")

    def teardown_method(self):
        self.oc_api.delete_project()

    def test_template_inside_cluster(self):
        if VERSION.startswith("3.3"):
            branch_to_test = "3.3"
        else:
            branch_to_test = "master"
        expected_output = "Welcome to your Rails application"
        template_json = self.oc_api.get_raw_url_for_json(
            container="rails-ex", branch=branch_to_test, dir="openshift/templates", filename="rails.json"
        )
        assert self.oc_api.deploy_template(
            template=template_json, name_in_template="rails-example", expected_output=expected_output,
            openshift_args=[f"SOURCE_REPOSITORY_REF={branch_to_test}", f"RUBY_VERSION={VERSION}", "NAME=rails-example"]
        )
        assert self.oc_api.template_deployed(name_in_template="rails-example")
        assert self.oc_api.check_response_inside_cluster(
            name_in_template="rails-example", expected_output=expected_output
        )

    def test_template_by_request(self):
        if VERSION.startswith("3.3"):
            branch_to_test = "3.3"
        else:
            branch_to_test = "master"
        expected_output = "Welcome to your Rails application"
        template_json = self.oc_api.get_raw_url_for_json(
            container="rails-ex", branch=branch_to_test, dir="openshift/templates", filename="rails.json"
        )
        assert self.oc_api.deploy_template(
            template=template_json, name_in_template="rails-example", expected_output=expected_output,
            openshift_args=[f"SOURCE_REPOSITORY_REF={branch_to_test}", f"RUBY_VERSION={VERSION}", "NAME=rails-example"]
        )
        assert self.oc_api.template_deployed(name_in_template="rails-example")
        assert self.oc_api.check_response_outside_cluster(
            name_in_template="rails-example", expected_output=expected_output
        )
