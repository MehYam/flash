package behaviors
{
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	import scripts.ShieldActor;
	import scripts.TankActor;

	public class AmmoFireSource
	{
		private var _ammoType:AmmoType;
		private var _damage:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _angle:Number;
		private var _level:uint;
		private var _turret:Boolean;

		public function AmmoFireSource(type:AmmoType, damage:Number, x:Number, y:Number, angle:Number = 0, level:uint = 0, turret:Boolean = false)
		{
			_ammoType = type;
			_damage = damage;
			_offsetX = x;
			_offsetY = y;
			_angle = angle;
			_level = level;
			_turret = turret;
		}

		static private var po_tmp:Point = new Point;
		public function fire(game:IGame, actor:Actor, damageMultiplier:Number = 1):Actor
		{
			const isPlayer:Boolean = actor == game.player;
			var ammo:Actor;
			switch(_ammoType) {
				case AmmoType.BULLET:
					ammo = Actor.createBullet(_level);
					break;
				case AmmoType.LASER:
				case AmmoType.HIGHLASER:
					ammo = Actor.createLaser(_level);
					break;
				case AmmoType.ROCKET:
					ammo = Actor.createRocket(_level, false);// no homing missiles for now !isPlayer && _level==2);
					break;
				case AmmoType.FUSION:
					ammo = Actor.createFusionBlast();
					break;
				case AmmoType.SHIELD:
					ammo = ShieldActor.create();
					break;
			}
			ammo.damage = _damage * damageMultiplier;
			const angle:Number = (_turret && actor is TankActor) ? (TankActor(actor).turretRotation) : actor.displayObject.rotation;

			Util.setPoint(po_tmp, actor.worldPos);
			po_tmp.offset(_offsetX, _offsetY);

			MathUtil.rotatePoint(actor.worldPos, po_tmp, angle);
			
			if (_ammoType != AmmoType.SHIELD)
			{
				// only because shield doesn't have an actorattr yet
				ammo.launchDegrees(po_tmp, angle + _angle);
			}
			if (isPlayer)
			{
				if (_ammoType == AmmoType.SHIELD)
				{
					game.addFriendly(ammo);
				}
				else
				{
					game.addFriendlyAmmo(ammo);
				}
			}
			else
			{
				game.addEnemyAmmo(ammo);
			}
			return ammo;
		}
		
		// hack: these exist just for shield activator
		public function get damage():Number
		{
			return _damage;
		}
		public function get offsetY():Number
		{
			return _offsetY;
		}
	}
}