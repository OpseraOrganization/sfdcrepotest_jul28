/**
 * Created by bkandov on 2019-07-02.
 */

public class NCP_InterfaceLogFromIpaaS_WS_Mock implements HttpCalloutMock {
	Map<String, HttpCalloutMock> requests;

	public NCP_InterfaceLogFromIpaaS_WS_Mock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	}

	public HTTPResponse respond(HTTPRequest req) {

		HttpCalloutMock mock = requests.get(req.getEndpoint());
		return mock.respond(req);
	}
}