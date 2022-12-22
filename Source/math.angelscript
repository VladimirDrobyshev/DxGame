
// 2D

vector2 vecSub(vector2 a, vector2 b)
{
	vector2 c;
	c.x = b.x - a.x;
	c.y = b.y - a.y;
	return c;
}

vector2 vecAdd(vector2 a, vector2 b)
{
	vector2 c;
	c.x = a.x + b.x;
	c.y = a.y + b.y;
	return c;
}

float vecLen(vector2 v)
{
	return sqrt(v.x * v.x + v.y * v.y);
}

float vecLenSq(vector2 v)
{
	return (v.x * v.x + v.y * v.y);
}

vector2 vecNorm(vector2 v)
{
	float len = vecLen(v);
	if (len == 0)
		return v;
	
	vector2 o;
	o.x = v.x / len;
	o.y = v.y / len;
	
	return o;
}

float Distance(vector2 a, vector2 b)
{
	vector2 v = vecSub(a, b);
	return vecLen(v);
}

vector2 vecScale(vector2 v, float s)
{
	vector2 o;
	o.x = v.x * s;
	o.y = v.y * s;
	
	return o;
}

// 3D

vector3 vecSub(vector3 a, vector3 b)
{
	vector3 c;
	c.x = b.x - a.x;
	c.y = b.y - a.y;
	c.z = b.z - a.z;
	return c;
}

vector3 vecAdd(vector3 a, vector3 b)
{
	vector3 c;
	c.x = a.x + b.x;
	c.y = a.y + b.y;
	c.z = a.z + b.z;
	return c;
}

float vecLen(vector3 v)
{
	return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

float vecLenSq(vector3 v)
{
	return (v.x * v.x + v.y * v.y + v.z * v.z);
}

vector3 vecNorm(vector3 v)
{
	float len = vecLen(v);
	if (len == 0)
		return v;
	
	vector3 o;
	o.x = v.x / len;
	o.y = v.y / len;
	o.z = v.z / len;
	
	return o;
}

float Distance(vector3 a, vector3 b)
{
	vector3 v = vecSub(a, b);
	return vecLen(v);
}

vector3 vecScale(vector3 v, float s)
{
	vector3 o;
	o.x = v.x * s;
	o.y = v.y * s;
	o.z = v.z * s;
	
	return o;
}



