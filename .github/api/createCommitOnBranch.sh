#!/bin/bash
# https://docs.github.com/en/graphql/reference/mutations#createcommitonbranch
GITHUB_HEAD_ID=$(git rev-parse HEAD)
GITHUB_FILE_CHANGES=$(rev <<< $(git diff --name-only $GITHUB_REF_NAME | awk '{system("contents=$(base64 -i "$1") && echo \"{ #path#: #"$1"#, #contents#: #$contents# },\"")}') | cut -c2- | rev | sed -e s/#/\\\"/g)
git diff --name-only $GITHUB_REF_NAME
curl -H "Authorization: bearer $GH_TOKEN" -d @- https://api.github.com/graphql <<EOF
{
  "query": "mutation(\$input:CreateCommitOnBranchInput!){createCommitOnBranch(input:\$input){commit{url}}}",
  "variables": {
    "input": {
      "branch": {
        "repositoryNameWithOwner": "$GITHUB_REPOSITORY",
        "branchName": "$GITHUB_REF_NAME"
      },
      "message": {
        "headline": "$GITHUB_JOB"
      },
      "fileChanges": {
        "additions": [$GITHUB_FILE_CHANGES]
      },
      "expectedHeadOid": "$GITHUB_HEAD_ID"
    }
  }
}
EOF
