#!/usr/bin/env python3
"""
HPAI-OS API Testing Script
Tests all major endpoints and authentication flows
"""

import json
import requests
import time
from typing import Optional, Dict, Any

class APITester:
    def __init__(self, base_url: str = "http://127.0.0.1:8000"):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.username: Optional[str] = None
        self.results = []

    def test(self, name: str, method: str, endpoint: str, expected_status: int = 200, 
             data: Optional[Dict[str, Any]] = None, use_auth: bool = False, files: Optional[Dict] = None):
        """Execute a test and record results"""
        url = f"{self.base_url}{endpoint}"
        headers = {"Content-Type": "application/json"}
        
        if use_auth and self.token:
            headers["Authorization"] = f"Bearer {self.token}"

        try:
            if method == "POST":
                if files:
                    response = requests.post(url, headers={"Authorization": f"Bearer {self.token}"} if use_auth else {}, files=files, timeout=10)
                else:
                    response = requests.post(url, json=data, headers=headers, timeout=10)
            elif method == "GET":
                response = requests.get(url, headers=headers, timeout=10)
            else:
                raise ValueError(f"Unknown method: {method}")

            status_ok = response.status_code == expected_status
            result = {
                "name": name,
                "status": "✓ PASS" if status_ok else "✗ FAIL",
                "expected": expected_status,
                "actual": response.status_code,
                "url": endpoint,
                "method": method
            }

            try:
                result["response"] = response.json()
            except:
                result["response"] = response.text[:200] if response.text else "(empty)"

            self.results.append(result)
            print(f"[{result['status']}] {name} ({response.status_code})")
            
            return response

        except Exception as e:
            result = {
                "name": name,
                "status": "✗ ERROR",
                "error": str(e),
                "url": endpoint,
                "method": method
            }
            self.results.append(result)
            print(f"[✗ ERROR] {name}: {str(e)}")
            return None

    def run_all_tests(self):
        """Run complete test suite"""
        print("\n" + "="*60)
        print("HPAI-OS API TEST SUITE")
        print("="*60 + "\n")

        # 1. Authentication Tests
        print("1. AUTHENTICATION TESTS")
        print("-" * 60)
        
        # Register new user
        reg_response = self.test(
            "Register new user",
            "POST",
            "/register",
            expected_status=200,
            data={
                "username": f"testuser_{int(time.time())}",
                "email": f"test_{int(time.time())}@example.com",
                "password": "TestPassword123!"
            }
        )

        # Login
        login_data = {
            "email": f"test_{int(time.time())-1}@example.com",
            "password": "TestPassword123!"
        }
        
        # Try with existing user or create and login
        login_response = self.test(
            "User login",
            "POST",
            "/login",
            expected_status=200,
            data={
                "email": "test@example.com",
                "password": "password123"
            }
        )

        # If login fails, register first
        if login_response and login_response.status_code == 200:
            data = login_response.json()
            self.token = data.get("access_token")
            self.username = data.get("username")
            print(f"   Token obtained: {self.token[:20]}...")
        else:
            print("   ⚠ Could not obtain token, registering new user...")
            register_response = self.test(
                "Register test user",
                "POST",
                "/register",
                expected_status=200,
                data={
                    "username": "testuser_demo",
                    "email": "demo@test.com",
                    "password": "Demo123456"
                }
            )
            
            if register_response and register_response.status_code == 200:
                login_response = self.test(
                    "Login after registration",
                    "POST",
                    "/login",
                    expected_status=200,
                    data={
                        "email": "demo@test.com",
                        "password": "Demo123456"
                    }
                )
                
                if login_response and login_response.status_code == 200:
                    data = login_response.json()
                    self.token = data.get("access_token")
                    self.username = data.get("username")
                    print(f"   Token obtained: {self.token[:20]}...")

        print()

        # 2. Token Verification Tests
        print("2. TOKEN VERIFICATION TESTS")
        print("-" * 60)
        
        if self.token:
            self.test(
                "Verify token validity",
                "GET",
                "/verify-token",
                expected_status=200,
                use_auth=True
            )
            print()
        else:
            print("⚠ Skipping token tests - no valid token\n")

        # 3. Chat Tests
        print("3. CHAT FUNCTIONALITY TESTS")
        print("-" * 60)
        
        if self.token:
            self.test(
                "Send chat message",
                "POST",
                "/chat",
                expected_status=200,
                data={"message": "Hello, how can you help me?"},
                use_auth=True
            )
            print()
        else:
            print("⚠ Skipping chat tests - no valid token\n")

        # 4. PDF Tests
        print("4. PDF FUNCTIONALITY TESTS")
        print("-" * 60)
        
        if self.token:
            # Try to create a test PDF
            try:
                from reportlab.pdfgen import canvas
                pdf_path = "test_document.pdf"
                c = canvas.Canvas(pdf_path)
                c.drawString(100, 750, "Test Document")
                c.drawString(100, 730, "This is a test PDF for HPAI-OS")
                c.save()
                
                print("   Created test PDF: test_document.pdf")
                
                # Try uploading PDF
                with open(pdf_path, 'rb') as f:
                    # Can't use self.test() for file uploads easily, do manual
                    headers = {"Authorization": f"Bearer {self.token}"}
                    files = {'file': f}
                    try:
                        response = requests.post(
                            f"{self.base_url}/upload-pdf",
                            headers=headers,
                            files=files,
                            timeout=10
                        )
                        status_ok = response.status_code == 200
                        print(f"   [{'✓ PASS' if status_ok else '✗ FAIL'}] Upload PDF ({response.status_code})")
                        self.results.append({
                            "name": "Upload PDF",
                            "status": "✓ PASS" if status_ok else "✗ FAIL",
                            "actual": response.status_code
                        })
                    except Exception as e:
                        print(f"   [✗ ERROR] Upload PDF: {e}")
                        self.results.append({
                            "name": "Upload PDF",
                            "status": "✗ ERROR",
                            "error": str(e)
                        })
                
                # Ask PDF question
                self.test(
                    "Ask question about PDF",
                    "POST",
                    "/ask-pdf",
                    expected_status=200,
                    data={"question": "What is this document about?"},
                    use_auth=True
                )
            except ImportError:
                print("   ⚠ reportlab not installed, skipping PDF upload test")
            
            print()
        else:
            print("⚠ Skipping PDF tests - no valid token\n")

        # 5. Error Handling Tests
        print("5. ERROR HANDLING TESTS")
        print("-" * 60)
        
        # Test 401 - No auth
        self.test(
            "Chat without auth (should fail)",
            "POST",
            "/chat",
            expected_status=401,
            data={"message": "Hello"}
        )
        
        # Test 400 - Empty message
        if self.token:
            self.test(
                "Chat with empty message (should fail)",
                "POST",
                "/chat",
                expected_status=400,
                data={"message": ""},
                use_auth=True
            )
        
        # Test invalid credentials
        self.test(
            "Login with invalid credentials",
            "POST",
            "/login",
            expected_status=401,
            data={
                "email": "nonexistent@test.com",
                "password": "wrongpassword"
            }
        )
        
        print()

        # Print Summary
        self._print_summary()

    def _print_summary(self):
        """Print test results summary"""
        print("="*60)
        print("TEST SUMMARY")
        print("="*60 + "\n")

        passed = sum(1 for r in self.results if "PASS" in r.get("status", ""))
        failed = sum(1 for r in self.results if "FAIL" in r.get("status", ""))
        errors = sum(1 for r in self.results if "ERROR" in r.get("status", ""))
        total = len(self.results)

        print(f"Total Tests: {total}")
        print(f"Passed:  ✓ {passed}")
        print(f"Failed:  ✗ {failed}")
        print(f"Errors:  ✗ {errors}")
        print()

        if failed > 0 or errors > 0:
            print("FAILED/ERROR TESTS:")
            for r in self.results:
                if "PASS" not in r.get("status", ""):
                    print(f"  - {r['name']}: {r.get('error', r.get('response', 'Unknown error'))}")
            print()

        success_rate = (passed / total * 100) if total > 0 else 0
        print(f"Success Rate: {success_rate:.1f}%")
        print()

        if success_rate >= 80:
            print("✓ APPLICATION IS READY FOR PRODUCTION")
        elif success_rate >= 50:
            print("⚠ APPLICATION NEEDS FIXES BEFORE PRODUCTION")
        else:
            print("✗ APPLICATION HAS CRITICAL ISSUES")

if __name__ == "__main__":
    import sys
    
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
    
    print(f"\nTesting API at: {base_url}\n")
    
    tester = APITester(base_url)
    tester.run_all_tests()
