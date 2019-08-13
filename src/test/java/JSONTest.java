import static org.junit.Assert.*;

import org.json.JSONObject;
import org.junit.Test;


public class JSONTest {

	@Test
	public void test() {
		String jsonString = "{\"collection-list\":[{\"id\":\"sample\",\"is-active\":true}]}";
		JSONObject obj = new JSONObject(jsonString);
		System.out.println(obj);
	}

}
