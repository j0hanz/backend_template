# Simple utility for creating the Cloudinary URL from a
# cloudinary_python.txt file
# Matt Rudge, November 2021

import re
import sys


def extract_cloudinary_credentials(file_path):
    """
    Extracts Cloudinary credentials from the given file.

    Arguments:
    file_path -- path to the file containing Cloudinary credentials

    Returns:
    A tuple containing (cloud_name, api_key, api_secret)
    """
    try:
        with open(file_path, 'r') as f:
            content = f.readlines()

        cloud_name = re.findall(r"'(.*?)'", content[15])[0]
        api_key = re.findall(r"'(.*?)'", content[16])[0]
        api_secret = re.findall(r"'(.*?)'", content[17])[0]

        return cloud_name, api_key, api_secret

    except FileNotFoundError:
        print(f"Error: The file {file_path} does not exist.")
        sys.exit(1)
    except IndexError:
        print(
            f"Error: The file {file_path} does not contain the expected format."
        )
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)


def main():
    file_path = "cloudinary_python.txt"
    cloud_name, api_key, api_secret = extract_cloudinary_credentials(file_path)
    print(f"cloudinary://{api_key}:{api_secret}@{cloud_name}")


if __name__ == "__main__":
    main()
