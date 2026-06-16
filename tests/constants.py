TAGS = {
    "rhel8": "-ubi8",
    "rhel9": "-ubi9",
    "rhel10": "-ubi10",
}


def is_test_allowed(os, version):
    if os == "rhel8" and version in ["2.5", "3.3"]:
        return True
    if os == "rhel9" and version in ["3.0", "3.3", "4.0"]:
        return True
    if os == "rhel10" and version in ["3.3", "4.0"]:
        return True
    return False
