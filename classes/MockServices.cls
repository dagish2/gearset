public class MockServices {

	public static String CompanySuccess() {
		return 
		'{' +
		'  "meta": {' +
		'    "success": true,' +
		'    "version": "1.0",' +
		'    "httpStatus": 200' +
		'  },' +
		'  "result": {' +
		'    "created_at": "2013-12-20T20:30:30Z",' +
		'    "deleted_at": null,' +
		'    "id": 4735,' +
		'    "name": "Acme Company, Inc.",' +
		'    "notes": null,' +
		'    "printer_login": 123456,' +
		'    "printer_pin": 6203,' +
		'    "start_date": "2013-12-31",' +
		'    "status": "active",' +
		'    "updated_at": "2013-12-20T20:30:30Z",' +
		'    "uuid": "0e3a2fc0-4bdd-0131-6a4b-10ddb1c23555",' +
		'    "weconnect_id": 19412' +
		'  }' +
		'}';
	}

	public static String CompanyFailure() {
		return
		'{' +
		'  "meta": {' +
		'    "success": false,' +
		'    "version": "1.0",' +
		'    "httpStatus": 406' +
		'  },' +
		'  "result": {' +
		'    "error": "Company exists with given UUID",' +
		'    "stack": null,' +
		'    "params": {' +
		'      "name": "Acme Company, Inc.",' +
		'      "printer_login": "123456",' +
		'      "start_date": "2013-12-31",' +
		'      "uuid": "0e3a2fc0-4bdd-0131-6a4b-10ddb1c23555",' +
		'      "company": {' +
		'        "name": "Acme Company, Inc.",' +
		'        "printer_login": "123456",' +
		'        "uuid": "0e3a2fc0-4bdd-0131-6a4b-10ddb1c23555",' +
		'        "start_date": "2013-12-31"' +
		'      }' +
		'    }' +
		'  }' +
		'}';
	}

	public static String MemberBulkMixedResult() {
		return
		'{' +
		'  "meta": {' +
		'    "success": true,' +
		'    "version": "1.0",' +
		'    "httpStatus": 200' +
		'  },' +
		'  "result": [' +
		'    {' +
		'      "uuid": "89d850f0-4bdd-0131-6a4b-10ddb1c23555",' +
		'      "success": false,' +
		'      "error": "Email has already been taken and Uuid has already been taken"' +
		'    },' +
		'    {' +
		'      "uuid": "3f1dd700-4bde-0131-6a4b-10ddb1c23555",' +
		'      "success": true' +
		'    }' +
		'  ]' +
		'}';
	}

	public static String PaymentSuccess() {
		return
		'{' +
		'  "meta": {' +
		'    "success": true,' +
		'    "version": "1.0",' +
		'    "httpStatus": 200' +
		'  },' +
		'  "result": {' +
		'    "url": "https://payments.wework.com/payment_info/123abcd"' +
		'  }' +
		'}';
	}
}