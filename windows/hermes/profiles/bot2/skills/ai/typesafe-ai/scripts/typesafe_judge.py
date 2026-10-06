#!/usr/bin/env python3
"""
TypeSafe / Jev Evaluation Script (Zero-dependency stdlib)
Performs System One evaluations via TypeSafe API (https://api.typesafe.ai/v1/systemone).
"""
import os
import sys
import json
import urllib.request
import urllib.error


def evaluate(state, questions, model="jev-latest", api_key=None):
    if not api_key:
        api_key = os.getenv("TYPESAFE_API_KEY")
    if not api_key:
        raise ValueError("TYPESAFE_API_KEY not found in environment")

    url = "https://api.typesafe.ai/v1/systemone"
    payload = {
        "state": state,
        "model": model,
        "questions": questions
    }

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "HermesAgent/TypeSafe"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_data = response.read().decode("utf-8")
            return json.loads(res_data)
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8")
        try:
            err_json = json.loads(err_body)
            return {"error": f"HTTP {e.code}: {err_json}"}
        except Exception:
            return {"error": f"HTTP {e.code}: {err_body}"}
    except Exception as e:
        return {"error": str(e)}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: python typesafe_judge.py '<json_request>'"}))
        sys.exit(1)

    try:
        request = json.loads(sys.argv[1])
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"Invalid JSON: {e}"}))
        sys.exit(1)

    state = request.get("state")
    questions = request.get("questions")
    model = request.get("model", "jev-latest")

    if not state or not questions:
        print(json.dumps({"error": "Missing 'state' or 'questions' in request"}))
        sys.exit(1)

    res = evaluate(state, questions, model)
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()