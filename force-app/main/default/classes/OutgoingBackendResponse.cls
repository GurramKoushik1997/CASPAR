public class OutgoingBackendResponse {

	public Boolean saved;
	public Integer caspar_id;
	public String temporary_password;
	public List<String> errors;

	public static OutgoingBackendResponse parse(String json) {
		return (OutgoingBackendResponse) System.JSON.deserialize(json, OutgoingBackendResponse.class);
	}
}