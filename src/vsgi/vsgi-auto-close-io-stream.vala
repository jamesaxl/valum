/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;

public class VSGI.AutoCloseIOStream : IOStream {

	private InputStream  _input_stream;
	private OutputStream _output_stream;

	public override InputStream input_stream {
		get {
			return _input_stream;
		}
	}

	public override OutputStream output_stream {
		get {
			return _output_stream;
		}
	}

	public AutoCloseIOStream (InputStream input_stream, OutputStream output_stream) {
		_input_stream  = input_stream;
		_output_stream = output_stream;
	}

	public override void dispose () {
		try {
			close ();
		} catch (IOError err) {
			critical (err.message);
		}
	}
}
