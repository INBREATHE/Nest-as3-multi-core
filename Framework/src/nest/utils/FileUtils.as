/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.utils
{
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;

public final class FileUtils
{
	static public function readStringFromFile(path:String):String {
		var result:String = "";
		const localFile:File = File.applicationDirectory.resolvePath(path);
		if(localFile.exists) {
			const fileStream:FileStream = new FileStream();
			fileStream.open(localFile, FileMode.READ);
			result = fileStream.readUTFBytes(fileStream.bytesAvailable);

			fileStream.close();
		}
		return result;
	}

	static public function readBytesFromFile( path:String, uncompressed:Boolean = false ):ByteArray {
		const file			  : File 			  = File.applicationDirectory.resolvePath( path );
		const fileStream	: FileStream 	= new FileStream();
		const byteArray	: ByteArray 	= new ByteArray();

//		trace("> FileUtils > readBytesFromFile:", file.exists, path);
		if( !file.exists ) return byteArray;

		fileStream.open( file, FileMode.READ );
		fileStream.readBytes( byteArray );
		if(uncompressed)
		try { byteArray.uncompress( CompressionAlgorithm.LZMA ); }
		catch ( e:Error ) { trace( ">\t FileUtils -> readBytesFromFile: The ByteArray uncompress problem!" ); }
		fileStream.close();

		return byteArray;
	}

	static public function writeBytesToFile(path:String, bytes:ByteArray, compression:Boolean = false):Boolean {
		var result:Boolean = true;

		trace("> FileUtils -> writeBytesToFile: begins");
		const file : File = File.applicationDirectory.resolvePath(path);
		trace("> FileUtils -> writeBytesToFile: file =", file.exists, file.nativePath);
		const fileStream : FileStream = new FileStream();
		if(compression) bytes.compress(CompressionAlgorithm.LZMA);
		trace("> FileUtils -> writeBytesToFile: compressed =" + compression);

		fileStream.open(file, FileMode.WRITE);
		fileStream.writeBytes(bytes);
		fileStream.close();

		return result;
	}
}
}