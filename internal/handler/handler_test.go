package handler

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHandlers(t *testing.T) {
	tests := []struct {
		name       string
		method     string
		target     string
		handler    http.HandlerFunc
		wantStatus int
		wantSubstr string
	}{
		{
			name:       "root returns hello api",
			method:     http.MethodGet,
			target:     "/",
			handler:    Root,
			wantStatus: http.StatusOK,
			wantSubstr: "hello api", // Root uses Fprintln so body ends with newline
		},
		{
			name:       "healthz ok",
			method:     http.MethodGet,
			target:     "/healthz",
			handler:    Healthz,
			wantStatus: http.StatusOK,
		},
		{
			name:       "readyz ok",
			method:     http.MethodGet,
			target:     "/readyz",
			handler:    Readyz,
			wantStatus: http.StatusOK,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequest(tc.method, tc.target, nil)
			rec := httptest.NewRecorder()

			tc.handler(rec, req)

			res := rec.Result()
			defer res.Body.Close()

			if res.StatusCode != tc.wantStatus {
				t.Fatalf("status: got %d, want %d", res.StatusCode, tc.wantStatus)
			}
			if tc.wantSubstr != "" {
				body := rec.Body.String()
				if !strings.Contains(body, tc.wantSubstr) {
					t.Fatalf("body: want substring %q, got %q", tc.wantSubstr, body)
				}
			}
		})
	}
}
