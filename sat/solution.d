module sat.solution;

private import std.stdio;
private import jive.array;

import sat.types, sat.clause;

final class Solution
{
	private Array!Lit assign; // undef / elim / fixed
	private ClauseStorage extension;

	int varCount() const @property { return cast(int)assign.length; }

	this(int n)
	{
		assign.resize(n, Lit.undef);
		extension = new ClauseStorage;
	}

	/** set a (previously unset) literal */
	void setLiteral(Lit l)
	{
		assert(assign[l.var] == Lit.undef);
		assign[l.var] = Lit.one^l.sign;
	}

	/** eliminate a by setting it equivalent to b */
	void setEquivalence(Lit a, Lit b)
	{
		assert(assign[a.var] == Lit.undef);
		assign[a.var] = Lit.elim;
		extension.addBinary(a, b.neg, true);
		extension.addBinary(a.neg, b, true);
	}

	void extend()
	{
		foreach_reverse(ref c; extension)
		{
			if(!isSatisfied(c[]))
			{
				assert(assign[c[0].var] == Lit.elim);
				assign[c[0].var] = Lit.one^c[0].sign;
			}
		}
	}

	void print(File file) const
	{
		file.writefln("SAT");
		for(int i = 0; i < varCount; ++i)
		{
			if(!assign[i].fixed)
				throw new Exception("tried to output an incomplete assignment");
			file.writef(i==0?"%s":" %s", Lit(i, assign[i].sign));
		}
		file.writefln(" 0");
	}

	bool isSatisfied(Lit a) const
	{
		return (assign[a.var]^a.sign) == Lit.one;
	}

	bool isSatisfied(Lit a, Lit b) const
	{
		return isSatisfied(a) || isSatisfied(b);
	}

	bool isSatisfied(Lit a, Lit b, Lit c) const
	{
		return isSatisfied(a) || isSatisfied(b) || isSatisfied(c);
	}

	bool isSatisfied(const(Lit)[] c) const
	{
		foreach(l; c)
			if(isSatisfied(l))
				return true;
		return false;
	}
}