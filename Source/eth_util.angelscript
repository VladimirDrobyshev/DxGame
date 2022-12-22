/*-----------------------------------------------------------------------

 Ethanon Engine (C) Copyright 2009-2011 André Santee
 http://www.asantee.net/gamespace/ethanon/

    This file is part of Ethanon Engine.

    Ethanon Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    Ethanon Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Ethanon Engine. If not, see
    <http://www.gnu.org/licenses/>.

-----------------------------------------------------------------------*/

/// Returns true if the point p is in screen
bool isPointInScreen(vector2 p)
{
	p -= GetCameraPos();
	if (p.x < 0 || p.y < 0 || p.x > GetScreenSize().x || p.y > GetScreenSize().y)
		return false;
	else
		return true;
}

/// Creates a string from a vector3
string vector3ToString(const vector3 v3)
{
	return "(" + v3.x + ", " + v3.y + ", " + v3.z + ")";
}

/// Creates a string from a vector2
string vector2ToString(const vector2 v2)
{
	return "(" + v2.x + ", " + v2.y + ")";
}

/// Converts a pixel format assignment to a stringInput
string formatToString(const PIXEL_FORMAT format)
{
	if (format == PF32BIT)
		return "32";
	if (format == PF16BIT)
		return "16";
	return "unknown";
}

/// Creates an array containing every entity within thisEntity's bucket and the buckets around it, including itself
void getSurroundingEntities(ETHEntity @thisEntity, ETHEntityArray @outEntities)
{
	const vector2 bucket(thisEntity.GetCurrentBucket());
	GetEntitiesFromBucket(bucket, outEntities);
	GetEntitiesFromBucket(bucket+vector2(1,0), outEntities);
	GetEntitiesFromBucket(bucket+vector2(1,1), outEntities);
	GetEntitiesFromBucket(bucket+vector2(0,1), outEntities);
	GetEntitiesFromBucket(bucket+vector2(-1,1), outEntities);
	GetEntitiesFromBucket(bucket+vector2(-1,0), outEntities);
	GetEntitiesFromBucket(bucket+vector2(-1,-1), outEntities);
	GetEntitiesFromBucket(bucket+vector2(0,-1), outEntities);
	GetEntitiesFromBucket(bucket+vector2(1,-1), outEntities);
}

/// Finds an entity named 'entityName' among all thisEntity's surrounding entities.
ETHEntity @findAmongNeighbourEntities(ETHEntity @thisEntity, const string entityName)
{
	ETHEntityArray entityArray;
	getSurroundingEntities(thisEntity, entityArray);
	uint size = entityArray.size();
	for (uint t=0; t<size; t++)
	{
		if (entityArray[t].GetEntityName() == entityName)
		{
			return @entityArray[t];
		}
	}
	return null;
}

/// Scans the screen for an entity named 'name' and returns a handle to it if found.
ETHEntity @findEntityInScreen(const string name)
{
	ETHEntityArray entities;
	GetVisibleEntities(entities);
	for (uint t=0; t<entities.size(); t++)
	{
		if (entities[t].GetEntityName() == name)
		{
			return entities[t];
		}
	}
	return null;
}

class Sphere
{
	Sphere(const vector3 _pos, const float _radius)
	{
		pos = _pos;
		radius = _radius;
	}
	vector3 pos;
	float radius;
}

bool intersectSpheres(const Sphere @a, const Sphere @b)
{
	if (distance(a.pos, b.pos) > a.radius+b.radius)
		return false;
	else
		return true;
}

class Circle
{
	Circle(const vector2 _pos, const float _radius)
	{
		pos = _pos;
		radius = _radius;
	}
	vector2 pos;
	float radius;
}

bool intersectCircles(const Circle @a, const Circle @b)
{
	if (distance(a.pos, b.pos) > a.radius+b.radius)
		return false;
	else
		return true;
}

/* 
 * stringInput class:
 * Places an input area on screen where the user can type texts
 */
class stringInput
{
	stringInput()
	{
		blinkTime = 300;
		lastBlink = 0;
		showingCarret = 1;
	}
	void PlaceInput(const string text, const vector2 pos, const string font, const uint color)
	{
		const uint time = GetTime();
		if ((time-lastBlink) > blinkTime)
		{
			showingCarret = showingCarret==0 ? 1 : 0;
			lastBlink = GetTime();
		}
	
		ETHInput @input = GetInputHandle();
		
		string lastInput = input.GetLastCharInput();
		if (lastInput != "")
		{
			ss += lastInput;
		}
		
		if (input.GetKeyState(K_BACKSPACE) == KS_HIT || input.GetKeyState(K_LEFT) == KS_HIT)
		{
			const uint len = ss.length();
			if (len > 0)
				ss.resize(len-1);
		}
		
		string outputString = text + ": " + ss;
		if (showingCarret==1)
			outputString += "|";
		DrawText(pos, outputString, font, color);
	}
	
	string GetString()
	{
		return ss;
	}
	
	private uint blinkTime;
	private uint lastBlink;
	private uint showingCarret;
	private string ss;
}

/* 
 * frameTimer class:
 * This object helps handling keyframe animation
 */
class frameTimer
{
	frameTimer()
	{
		m_currentFrame = m_currentFirst = m_currentLast = 0;
		m_lastTime = 0;
	}

	uint Get()
	{
		return m_currentFrame;
	}

	uint Set(const uint first, const uint last, const uint stride)
	{
		if (first != m_currentFirst || last != m_currentLast)
		{
			m_currentFrame = first;
			m_currentFirst = first;
			m_currentLast  = last;
			m_lastTime = GetTime();
			return m_currentFrame;
		}

		if (GetTime()-m_lastTime > stride)
		{
			m_currentFrame++;
			if (m_currentFrame > last)
				m_currentFrame = first;
			m_lastTime = GetTime();
		}

		return m_currentFrame;
	}

	private uint m_lastTime;
	private uint m_currentFirst;
	private uint m_currentLast;
	private uint m_currentFrame;
}
