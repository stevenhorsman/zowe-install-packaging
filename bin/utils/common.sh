#!/bin/sh

################################################################################
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright IBM Corporation 2020
################################################################################

print_error_message() {
  message=$1
  #output an error and add to the count
  if [[ -z "${ERRORS_FOUND}" ]];
  then
    ERRORS_FOUND=0
  fi

  # echo error to standard out and err - this was requested so that the errors go into STDOUT of the job
  # and save people going into STDERR (and make it inline with the rest of the logs), but it does result
  # in double outputting when called from shell environment, so maybe we should reconsider?
  echo "Error ${ERRORS_FOUND}: ${message}" 1>&2
  print_message "Error ${ERRORS_FOUND}: ${message}"

  let "ERRORS_FOUND=${ERRORS_FOUND}+1"
}

# In future we can add timestamps/message ids here
print_message() {
  message=$1
  echo "${message}"
}

# If LOG_FILE is an writable file then output to it, otherwise echo instead
log_message() {
  message=$1
  if [[ -n "${LOG_FILE}" ]] && [[ -w "${LOG_FILE}" ]];
  then
    echo ${message} >> $LOG_FILE 
  else
    echo ${message}
  fi
}

###############################
# Check if there are errors registered
#
# Notes: this function is for Zowe runtime, it requires INSTANCE_DIR variable.
#
# Notes: any error should increase global variable ERRORS_FOUND by 1.
runtime_check_for_validation_errors_found() {
  if [[ ${ERRORS_FOUND} > 0 ]]; then
    print_message "${ERRORS_FOUND} errors were found during validatation, please check the message, correct any properties required in ${INSTANCE_DIR}/instance.env and re-launch Zowe"
    if [ ! "${ZWE_IGNORE_VALIDATION_ERRORS}" = "true" ]; then
      exit ${ERRORS_FOUND}
    fi
  fi
}
