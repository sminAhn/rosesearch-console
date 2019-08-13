import static org.junit.Assert.*;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import org.junit.Test;


public class URLEncodeTest {

	@Test
	public void test() throws UnsupportedEncodingException {
		String uri = "/context/something/do?a=1&b=2&c=3";
		String encodedUri = URLEncoder.encode(uri, "UTF-8");
		
		System.out.println(uri);
		System.out.println(encodedUri);
	}

}
