import os
import subprocess
import json

def check_file_exists():
    submission_dir = '/autograder/submission'
    for filename in os.listdir(submission_dir):
        if filename.startswith('PSet') and filename.endswith('.lagda.md'):
            return filename
    return None

if __name__ == '__main__':
    filename = check_file_exists()
    if filename is None:
        result = {
            "tests": [
                {
                    "score": 0,
                    "max_score": 0,
                    "name": "No literate Agda file found",
                    "output_format": "text"
                }
            ]
        }
    else:
        try:
            result = subprocess.run(['agda', '--html', '--html-highlight=code', filename], capture_output=True, text=True)
            output = result.stdout + result.stderr
        except Exception as e:
            output = str(e)

        result = {
            "tests": [
                {
                    "score": 0,
                    "max_score": 0,
                    "output": output,
                    "name": "Agda typechecking",
                    "output_format": "text"
                },
                {
                    "score": 0,
                    "max_score": 0,
                    "name": "Agda code",
                    "output": open('/autograder/submission/' + filename, 'r').read(),
                    "output_format": "md"
                }
            ]
        }

    with open('/autograder/results/results.json', 'w') as f:
        json.dump(result, f, indent=4)