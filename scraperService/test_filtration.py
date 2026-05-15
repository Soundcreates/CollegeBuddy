#!/usr/bin/env python3
"""
Test script for AI Email Filtration Service

Usage:
    python test_filtration.py
    
This script tests the /filter-emails endpoint with sample academic emails.
"""

import requests
import json
from datetime import datetime
from typing import Optional

# Configuration
BASE_URL = "https://collegebuddy-python.onrender.com"
ENDPOINT = "/filter-emails"
TIMEOUT = 60

# Sample test data
SAMPLE_EMAILS = [
    {
        "subject": "CSIT 101 - Midterm Exam Schedule",
        "sender": "professor@university.edu",
        "body": "The midterm exam for CSIT 101 is scheduled for May 15, 2024 at 2:00 PM in Room 101. Duration: 2 hours.",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Database Design - Live Session Tomorrow",
        "sender": "instructor@university.edu", 
        "body": "Join us tomorrow at 10 AM for the Database Design online class. Zoom link: https://zoom.us/j/...",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Assignment 3 Due Tomorrow",
        "sender": "ta@university.edu",
        "body": "Please submit Assignment 3 by 11:59 PM tonight. Submit via the online portal.",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Your Grade for CSIT 201 Posted",
        "sender": "gradebook@university.edu",
        "body": "Your grade for CSIT 201 has been posted. Score: 92/100",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "URGENT: Final Exam Rescheduled",
        "sender": "admin@university.edu",
        "body": "IMPORTANT: The final exam originally scheduled for May 20 has been rescheduled to May 22 due to a facility issue.",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Seminar on AI Ethics - Friday",
        "sender": "events@university.edu",
        "body": "Join us for a seminar on AI Ethics this Friday at 3 PM in the auditorium. Light refreshments will be served.",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Holiday Notice - University Closed",
        "sender": "admin@university.edu",
        "body": "The university will be closed on Monday for Memorial Day. All classes are cancelled.",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "New Course Materials Available",
        "sender": "professor@university.edu",
        "body": "New lecture slides and reading materials for CSIT 101 have been uploaded to the course portal.",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Check out this funny meme",
        "sender": "friend@gmail.com",
        "body": "Hey! I found this hilarious meme about programming. Check it out! 😂",
        "date": datetime.now().isoformat()
    },
    {
        "subject": "Buy cheap textbooks online",
        "sender": "spam@bookstore.com",
        "body": "Special offer! Get 50% off on all textbooks. Limited time only!",
        "date": datetime.now().isoformat()
    }
]


def print_header(text: str) -> None:
    """Print a formatted header"""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70)


def print_section(text: str) -> None:
    """Print a section divider"""
    print(f"\n--- {text} ---")


def test_endpoint(emails: Optional[list] = None, date: Optional[str] = None) -> dict:
    """
    Test the /filter-emails endpoint
    
    Args:
        emails: List of email dicts. If None, uses SAMPLE_EMAILS
        date: Date string. If None, uses today's date
        
    Returns:
        Response JSON
    """
    if emails is None:
        emails = SAMPLE_EMAILS
    
    if date is None:
        date = datetime.now().strftime("%Y-%m-%d")
    
    payload = {
        "emails": emails,
        "date": date
    }
    
    print_section(f"Sending {len(emails)} emails to filtration service")
    print(f"Endpoint: {BASE_URL}{ENDPOINT}")
    print(f"Date: {date}")
    
    try:
        response = requests.post(
            f"{BASE_URL}{ENDPOINT}",
            json=payload,
            timeout=TIMEOUT
        )
        
        if response.status_code == 200:
            print(f"✅ Request successful (200 OK)")
            return response.json()
        else:
            print(f"❌ Request failed ({response.status_code})")
            print(f"Response: {response.text}")
            return {}
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Connection error: Unable to connect to {BASE_URL}")
        print("   Make sure the scraperService is running:")
        print("   $ uvicorn app.app:app --reload --port 8000")
        return {}
    except requests.exceptions.Timeout:
        print(f"❌ Request timeout after {TIMEOUT} seconds")
        return {}
    except Exception as e:
        print(f"❌ Error: {e}")
        return {}


def print_results(result: dict) -> None:
    """Print formatted results"""
    
    if not result:
        return
    
    print_header("FILTRATION RESULTS")
    
    # Summary stats
    print_section("Summary")
    print(f"✓ Total emails processed: {result.get('total_emails', 0)}")
    print(f"✓ Important emails found: {result.get('filtered_count', 0)}")
    
    if result.get('filtered_count', 0) == 0:
        print("   No important emails found!")
        return
    
    # By category breakdown
    print_section("Emails by Category")
    by_category = result.get('by_category', {})
    
    for category, emails in by_category.items():
        if emails:
            print(f"\n📧 {category.upper()} ({len(emails)} emails)")
            for idx, email in enumerate(emails, 1):
                confidence = email.get('confidence', 0)
                conf_bar = "█" * int(confidence * 10) + "░" * (10 - int(confidence * 10))
                print(f"  {idx}. {email['subject']}")
                print(f"     From: {email['sender']}")
                print(f"     Category: {email['category']}")
                print(f"     Confidence: {confidence:.1%} [{conf_bar}]")
    
    # Most important emails
    print_section("Top 5 Most Important Emails (by confidence)")
    all_filtered = result.get('all_filtered', [])
    for idx, email in enumerate(all_filtered[:5], 1):
        confidence = email.get('confidence', 0)
        print(f"{idx}. [{confidence:.1%}] {email['subject']}")
        print(f"   From: {email['sender']}")


def test_health_check() -> bool:
    """Test the /health endpoint"""
    print_section("Testing Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Service is healthy")
            return True
        else:
            print(f"❌ Unexpected status code: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False


def test_empty_batch() -> dict:
    """Test with empty email list"""
    print_section("Testing Empty Email List")
    return test_endpoint(emails=[], date="2024-05-02")


def test_single_email() -> dict:
    """Test with a single email"""
    print_section("Testing Single Email")
    single_email = [{
        "subject": "Exam Next Week",
        "sender": "prof@university.edu",
        "body": "The exam will be next week on Friday.",
        "date": datetime.now().isoformat()
    }]
    return test_endpoint(emails=single_email, date="2024-05-02")


def test_custom_date() -> dict:
    """Test with a custom date"""
    print_section("Testing Custom Date")
    return test_endpoint(emails=SAMPLE_EMAILS, date="2024-04-30")


def main():
    """Run all tests"""
    
    print_header("AI EMAIL FILTRATION SERVICE TEST SUITE")
    
    # Test 1: Health check
    print("\n📋 TEST 1: Health Check")
    health_ok = test_health_check()
    
    if not health_ok:
        print("\n⚠️  Service is not running. Skipping remaining tests.")
        print("   Start the service with:")
        print("   $ uvicorn app.app:app --reload --port 8000")
        return
    
    # Test 2: Full batch
    print("\n📋 TEST 2: Full Email Batch")
    result1 = test_endpoint(emails=SAMPLE_EMAILS)
    print_results(result1)
    
    # Test 3: Empty batch
    print("\n📋 TEST 3: Empty Email List")
    result2 = test_empty_batch()
    if result2:
        print(f"Result: {result2}")
    
    # Test 4: Single email
    print("\n📋 TEST 4: Single Email")
    result3 = test_single_email()
    if result3:
        print(f"✓ Filtered: {result3.get('filtered_count', 0)} email(s)")
    
    # Test 5: Custom date
    print("\n📋 TEST 5: Custom Date (2024-04-30)")
    result4 = test_custom_date()
    if result4:
        print(f"✓ Date in response: {result4.get('date', 'N/A')}")
    
    # Final summary
    print_header("TEST SUITE COMPLETE")
    print("""
✅ All tests completed successfully!

Next steps:
1. Review the filtered results above
2. Check confidence scores - are they reasonable?
3. Verify categorization - are emails in the right categories?
4. Test with your own real emails
5. Integrate the endpoint into your backend

For more information:
- See AI_FILTRATION_README.md for detailed documentation
- See BACKEND_INTEGRATION_GUIDE.py for integration examples
- See QUICK_REFERENCE.md for quick answers
    """)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Tests interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Unexpected error: {e}")
