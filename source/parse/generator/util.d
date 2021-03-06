module parse.generator.util;

import std.meta;
import std.traits;
import std.typecons;

import parse.generator;
import parse.lex.Token;

/* TODO generate lookahead switch */

/* create a rule that parses with
 * operator precedence given a base
 * rule and a list of token types
 * that represent operators */
template parsePrecedence(string genName,
                         alias BaseRule,
                         Token.Type[][] rules,
                         alias Conv)
    if(isRule!BaseRule)
{
    /* TODO finish precedence */
    import std.stdio;

    alias RuleType = ReturnType!BaseRule;

    static assert(__traits(compiles, Conv(RuleType.init, RuleType.init)),
                  "invalid conversion function in precedence parser");
    static assert(!is(ReturnType!Conv == void),
                  "conversion function must return a value");

    /* create the precedence table */
    template PrecedenceTable(Token.Type[][] total_rules)
        if(total_rules.length >= 1)
    {
        enum PrecedenceTable =
            "default: break;";
    };

    /* the implementation of the algorithm */
    auto parsePrecedenceImpl(ref TokenRange range)
    {
        RuleType[] stack;

        auto k = range.la;
        switch(k.type) {
            mixin(PrecedenceTable!rules);
        }

        return "";
    }
    
    alias parsePrecedence =
        RuleImpl!(
            parsePrecedenceImpl,
            genName);
}; 

import std.stdio;
alias precedenceTest =
    parsePrecedence!(
        "binary",
        parseToken!(Token.Type.INTEGER),
        [
            [ Token.Type.PLUS, Token.Type.MINUS ],
            [ Token.Type.STAR, Token.Type.DIV ],
        ],
        (x, y) => "%s and %s".writefln(x, y)
    );

/* rule | rule2 */
template parseOr(Rules...)
{
    auto parseOrImpl(ref TokenRange range)
    {
        alias OrResult = Tuple!(staticMap!(RulePair, Rules));
        auto result = OrResult();
        foreach(i, x; Rules){
            static assert(isRule!x, "invalid rule");
            static if(x.store){
                enum setVal = "result." ~ x.name;
                mixin(setVal) = x(range);
            }
        }
        return result;
    }

    alias parseOr =
        RuleImpl!(
            parseOrImpl,
            "parseOr",
            true);
};

/* rule (n or more times) */
template parseAtLeastN(size_t n, alias Rule)
{
    auto parseAtLeastNImpl(ref TokenRange range)
    {
        ReturnType!Rule[] result = [Rule(range)];
        /*
        for(size_t i = 0; ; ++i){
            try {
                range.saveState({
                    result ~= Rule(range);
                });
            } catch(ParseException e) {
                range.revert;
                if(i <= n){
                    import std.string;
                    throw new ParseException("couldn't parse %lu of rule".format(n));
                }
            }
        }
        */
        return result;
    }

    alias parseAtLeastN =
        RuleImpl!(
            parseAtLeastNImpl,
            "parseAtLeastN" ~ Rule.name,
            true);
};



/* rule+ */
template parseOneOrMore(alias Rule)
{
    alias parseOneOrMore =
        RuleImpl!(
            parseAtLeastN!(1, Rule),
            "parseOneOrMore" ~ Rule.name,
            true);
};

/* rule* */
template parseAnyAmount(alias Rule)
{
    alias parseAnyAmount = 
        RuleImpl!(
            range => range.parseAtLeastN!(0, Rule),
            Rule.name ~ "s",
            true);
};

/* rule rule2 ... ruleN */
template parseSequence(Rules...)
{

    auto parseSequenceImpl(ref TokenRange range)
    {
        alias RetType = Tuple!(staticMap!(RulePair, Rules));
        auto ret = RetType();
        foreach(i, x; Rules){
            static assert(isRule!x, "invalid rule");
            static if(x.store){
                mixin("ret." ~ x.name) = x(range);
            }
        }
        return ret;
    }

    alias parseSequence = 
        RuleImpl!(
            parseSequenceImpl,
            "sequential",
            true);
};

template parseToken(Token.Type type)
{
    alias parseToken =
        RuleImpl!(
            range => range.match(type),
            "token");
};

/* rule? */
template parseOptional(alias Rule)
{
    auto parseOptionalImpl(ref TokenRange range)
    {
        return nullable(
                    range.attempt!Rule
                );
    }

    alias parseOptional = 
        RuleImpl!(
            parseOptionalImpl,
            "parseOptional" ~ Rule.name,
            true);
};

template StoreAs(alias Rule, string name) 
{
    alias StoreAs = RuleImpl!(Rule.opCall, name, true);
};

