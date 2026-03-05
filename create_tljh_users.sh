#!/bin/bash
# Usage:
#   ./create_tljh_users.sh                          # prompts for token, creates test_user01-30
#   ./create_tljh_users.sh -t <token>               # creates test_user01-30
#   ./create_tljh_users.sh -l <namefile>            # prompts for token, creates users from file
#   ./create_tljh_users.sh -t <token> -l <namefile> # creates users from file

while getopts "t:l:" opt; do
  case $opt in
    t) TOKEN="$OPTARG" ;;
    l) NAME_FILE="$OPTARG" ;;
  esac
done

if [ $OPTIND -eq 1 ]; then
  echo "Usage:"
  echo "  ./create_tljh_users.sh -t <token> -l <namefile>   # create users from name list"
  echo "  ./create_tljh_users.sh -l <namefile>              # prompts for token, creates from list"
  echo "  ./create_tljh_users.sh -t <token>                 # prompts for count, creates test users"
  echo ""
  echo "Options:"
  echo "  -t  Admin token"
  echo "  -l  Path to name list file (one username per line)"
  exit 0
fi

if [ -z "$TOKEN" ]; then
  read -rsp "Enter JupyterHub admin token: " TOKEN
  echo ""
fi

if [ -n "$NAME_FILE" ]; then
  if [ ! -f "$NAME_FILE" ]; then
    echo "File not found: $NAME_FILE"
    exit 1
  fi
  while IFS= read -r USERNAME || [ -n "$USERNAME" ]; do
    [ -z "$USERNAME" ] && continue
    curl -s -X POST \
      -H "Authorization: token $TOKEN" \
      http://localhost/hub/api/users/$USERNAME
    echo "Created $USERNAME"
  done < "$NAME_FILE"
else
  read -rp "How many test users? " COUNT
  for i in $(seq -w 1 $COUNT); do
    USER="test_user$i"
    curl -s -X POST \
      -H "Authorization: token $TOKEN" \
      http://localhost/hub/api/users/$USER
    echo "Created $USER"
  done
fi

echo "Done."
