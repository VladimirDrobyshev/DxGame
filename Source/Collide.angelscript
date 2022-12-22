#include "eth_util.angelscript"

bool collide(collisionBox b1, collisionBox b2)
{
	if (b1.pos.x + b1.size.x / 2 <= b2.pos.x - b2.size.x / 2) return false; 
	if (b1.pos.y + b1.size.y / 2 <= b2.pos.y - b2.size.y / 2) return false;

	if (b2.pos.x + b2.size.x / 2 <= b1.pos.x - b1.size.x / 2) return false; 
	if (b2.pos.y + b2.size.y / 2 <= b1.pos.y - b1.size.y / 2) return false;

	if (b1.pos.z + b1.size.z / 2 <= b2.pos.z - b2.size.z / 2) return false;
	if (b2.pos.z + b2.size.z / 2 <= b1.pos.z - b1.size.z / 2) return false;
	return true;
}

collisionBox getAbsoluteCollisionBox(ETHEntity@ entity)
{
	collisionBox box = entity.GetCollisionBox();
	box.pos += entity.GetPosition();
	return box;
}

interface EntityChooser
{
	bool choose(ETHEntity@ entity);
}
class DefaultChooser : EntityChooser { bool choose(ETHEntity@ entity) { return true; } }
class DynamicChooser : EntityChooser { bool choose(ETHEntity@ entity) { return !entity.IsStatic(); } }
class StaticChooser  : EntityChooser { bool choose(ETHEntity@ entity) { return entity.IsStatic(); } }

class NamedChooser	 : EntityChooser {
	private string name;
	NamedChooser(string entityName) {
		name = entityName;
	}
	
	bool choose(ETHEntity@ entity) { 
		return (entity.GetEntityName() == name);
	}
}

bool Collide(ETHEntity@ entity)
{
	ETHEntity@ other;
	return Collide(@entity, other);
}

bool CollideStatic(ETHEntity@ entity)
{
	ETHEntity@ other;
	return Collide(@entity, other, StaticChooser());
}

bool CollideDynamic(ETHEntity@ entity)
{
	ETHEntity@ other;
	return Collide(@entity, other, DynamicChooser());
}

bool CollideStatic(ETHEntity@ entity, ETHEntity@ &out otherOut)
{
	return Collide(@entity, otherOut, StaticChooser());
}

bool CollideDynamic(ETHEntity@ entity, ETHEntity@ &out otherOut)
{
	return Collide(@entity, otherOut, DynamicChooser());
}

bool Collide(ETHEntity@ entity, ETHEntity@ &out otherOut)
{
	return Collide(@entity, otherOut, DefaultChooser());
}

bool Collide(ETHEntity@ entity, ETHEntity@ &out otherOut, EntityChooser@ chooser)
{
	if (entity is null)
		return false;
	
	if (!entity.Collidable())
	{
		return false;
	}

	ETHEntityArray entities;
	getSurroundingEntities(entity, entities);

	const uint size = entities.size();
	for (uint t = 0; t < size; t++)
	{
		ETHEntity@ other = @(entities[t]);
		if (other.Collidable() && entity.GetID() != other.GetID() && chooser.choose(other))
		{
			if (collide(getAbsoluteCollisionBox(entity), getAbsoluteCollisionBox(other)))
			{
				@otherOut = @other;
				return true;
			}
		}
	}
	return false;
}

// Vasin: callback collisions

funcdef bool CollideCallbackFunc(ETHEntity@, ETHEntity@);

bool CollideCallback(ETHEntity@ entity, CollideCallbackFunc@ OnCollide, EntityChooser@ chooser) {
	if (entity is null)
		return false;
	
	if (!entity.Collidable()) {
		return false;
	}

	ETHEntityArray entities;
	getSurroundingEntities(entity, entities);

	const uint size = entities.size();
	bool result = false;
	for (uint t = 0; t < size; t++)	{
		ETHEntity@ other = @(entities[t]);
		if (other.Collidable() && entity.GetID() != other.GetID() && chooser.choose(other)) {
			if (collide(getAbsoluteCollisionBox(entity), getAbsoluteCollisionBox(other))) {
				bool temp = OnCollide(entity, other);
				result = (result || temp);
			}
		}
	}
	return result;
}

bool CollideDynamicCallback(ETHEntity@ entity, CollideCallbackFunc@ OnCollide) {
	return CollideCallback(entity, OnCollide, DynamicChooser());
}

