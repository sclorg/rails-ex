.PHONY: test-openshift-4
test-openshift-4:
	cd tests && PYTHONPATH=$(CURDIR) python3.12 -m pytest -s -rA --showlocals -vv test_.py