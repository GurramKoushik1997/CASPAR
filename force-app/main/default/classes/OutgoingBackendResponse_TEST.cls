@IsTest
public class OutgoingBackendResponse_TEST {

	static testMethod void testParse() {
		String json = '{'+
		'  \"saved\": true,'+
		'  \"caspar_id\": 123,'+
		'  \"temporary_password\": \"398d8cd5afec21fb\",'+
		'\"errors\": [ \"Name is missing\", \"Email is already taken\" ]'+
		'}';
		OutgoingBackendResponse obj = OutgoingBackendResponse.parse(json);
		System.assert(obj != null);
	}
}