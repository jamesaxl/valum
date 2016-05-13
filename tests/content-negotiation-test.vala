using Valum;
using Valum.ContentNegotiation;
using VSGI.Mock;

public int main (string[] args) {
	Test.init (ref args);

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/negotiate", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

		var reached = false;
		try {
			negotiate ("Accept", "text/html", (req, res, next, ctx, content_type) => {
				reached = true;
				assert ("text/html" == content_type);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		// explicitly refuse the content type with 'q=0'
		reached = false;
		try {
			negotiate ("Accept", "text/xml", () => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		reached = false;
		try {
			negotiate ("Accept", "application/octet-stream", () => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		// no expectations always refuse
		reached = false;
		try {
			negotiate ("Accept", "", () => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		// header is missing, so forward unconditionnaly
		assert (null == req.headers.get_one ("Accept-Encoding"));
		reached = false;
		try {
			negotiate ("Accept-Encoding", "utf-8", () => {
				reached = true;
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/negotiate/multiple", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0.2");

		try {
			negotiate ("Accept", "text/xml, text/html", (req, res, next, ctx, content_type) => {
				assert ("text/html" == content_type);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/negotiate/quality", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		res.headers.append ("Accept", "application/json, text/xml; q=0.9");

		// 0.9 * 0.3 > 1 * 0.2
		try {
			negotiate ("Accept", "application/json; q=0.2, text/xml; q=0.3", (req, res, next, ctx, choice) => {
				assert ("text/xml" == choice);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}

		// 1 * 0.4 > 0.9 * 0.3
		try {
			negotiate ("Accept", "application/json; q=0.4, text/xml; q=0.3", (req, res, next, ctx, choice) => {
				assert ("application/json" == choice);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/accept", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/html");

		try {
			accept ("text/html", (req, res, next, ctx, content_type) => {
				assert ("text/html" == content_type);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/html" == res.headers.get_content_type (null));

		var reached = false;
		try {
			accept ("text/xml", (req, res, next, ctx, content_type) => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/accept/any", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "*/*");

		try {
			accept ("text/html", (req, res, next, ctx, content_type) => {
				assert ("text/html" == content_type);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/html" == res.headers.get_content_type (null));
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/accept/any_subtype", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/*");
		req.headers.append ("Accept-Encoding", "*");

		try {
		accept ("text/html", (req, res, next, ctx, content_type) => {
			assert ("text/html" == content_type);
			return true;
		}) (req, res, () => {
			assert_not_reached ();
		}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/html" == res.headers.get_content_type (null));

		try {
		accept ("text/xml", (req, res, next, ctx, content_type) => {
			assert ("text/xml" == content_type);
			return true;
		}) (req, res, () => {
			assert_not_reached ();
		}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/xml" == res.headers.get_content_type (null));

		try {
			accept ("application/json", () => {
				 assert_not_reached () ;
			 }) (req, res, () => {
				 assert_not_reached () ;
			 }, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_encoding/vendor_prefix", () => {
		var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Content-Encoding", "x-gzip");

		try {
			accept_encoding ("gzip", (req, res, next, ctx, encoding) => {
				assert ("gzip" == encoding);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}