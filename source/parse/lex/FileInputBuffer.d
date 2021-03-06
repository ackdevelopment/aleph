module parse.lex.FileInputBuffer;

import std.stdio;
import std.file;

import parse.lex.StringInputBuffer;
import parse.lex.Token;

public class FileInputBuffer : StringInputBuffer {
public:
    this(in string filename)
    {
        super(readText(filename), filename);
    }
    this(ref File file)
    {
        import std.range;
        import std.algorithm;
        import std.array;

        string res;
        char[] buf;
        while(file.readln(buf)){
            res ~= buf;
        }
        super(res);
    }
};
