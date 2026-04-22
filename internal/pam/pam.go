// Package pam wraps libpam for the `aqs pam authenticate` subcommand.
// The shell's Lock surface writes the password to stdin; this binary returns
// exit 0 on success and 1 on failure. Errors go to stderr.
package pam

/*
#cgo LDFLAGS: -lpam
#include <security/pam_appl.h>
#include <stdlib.h>
#include <string.h>

static int aqs_conv(int num_msg, const struct pam_message **msg,
                    struct pam_response **resp, void *appdata_ptr) {
    if (num_msg <= 0) return PAM_CONV_ERR;
    struct pam_response *r = (struct pam_response *)calloc(num_msg, sizeof(struct pam_response));
    if (!r) return PAM_BUF_ERR;
    const char *password = (const char *)appdata_ptr;
    for (int i = 0; i < num_msg; i++) {
        int style = msg[i]->msg_style;
        if (style == PAM_PROMPT_ECHO_OFF || style == PAM_PROMPT_ECHO_ON) {
            r[i].resp = strdup(password ? password : "");
        } else {
            r[i].resp = NULL;
        }
        r[i].resp_retcode = 0;
    }
    *resp = r;
    return PAM_SUCCESS;
}

static int aqs_pam_authenticate(const char *service, const char *user,
                                const char *password, char **err_out) {
    struct pam_conv conv = { aqs_conv, (void *)password };
    pam_handle_t *pamh = NULL;
    int ret = pam_start(service, user, &conv, &pamh);
    if (ret != PAM_SUCCESS) {
        if (err_out) *err_out = strdup(pam_strerror(pamh, ret));
        return ret;
    }
    ret = pam_authenticate(pamh, 0);
    if (ret == PAM_SUCCESS) {
        ret = pam_acct_mgmt(pamh, 0);
    }
    if (ret != PAM_SUCCESS && err_out) {
        *err_out = strdup(pam_strerror(pamh, ret));
    }
    pam_end(pamh, ret);
    return ret;
}
*/
import "C"

import (
	"errors"
	"fmt"
	"unsafe"
)

// Authenticate runs PAM against the given service for the given user with
// the provided password. Returns nil on success.
func Authenticate(service, user, password string) error {
	cservice := C.CString(service)
	defer C.free(unsafe.Pointer(cservice))
	cuser := C.CString(user)
	defer C.free(unsafe.Pointer(cuser))
	cpass := C.CString(password)
	defer C.free(unsafe.Pointer(cpass))

	var cerr *C.char
	ret := C.aqs_pam_authenticate(cservice, cuser, cpass, &cerr)
	if ret == C.PAM_SUCCESS {
		if cerr != nil {
			C.free(unsafe.Pointer(cerr))
		}
		return nil
	}
	msg := fmt.Sprintf("pam auth failed: code=%d", int(ret))
	if cerr != nil {
		msg = fmt.Sprintf("%s: %s", msg, C.GoString(cerr))
		C.free(unsafe.Pointer(cerr))
	}
	return errors.New(msg)
}
