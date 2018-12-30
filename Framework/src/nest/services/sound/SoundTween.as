package nest.services.sound
{
	import flash.utils.getTimer;

	public class SoundTween {

		public var startTime:int;
		public var startVolume:Number;
		public var endVolume:Number;
		public var duration:Number;

		protected var isMasterFade:Boolean;
		protected var _sound:SoundInstance;
		protected var _isComplete:Boolean;

		public var ended:Function;
		public var stopAtZero:Boolean;

		public function SoundTween(si:SoundInstance, endVolume:Number, duration:Number, isMasterFade:Boolean = false) {
			if(si){
				sound = si;
				startVolume = sound.volume;
			}

			this.isMasterFade = isMasterFade;
			init(startVolume, endVolume, duration);
		}

		public function update(t:int):Boolean {
			if(_isComplete){ return _isComplete; }

			if(isMasterFade){
				if(t - startTime < duration){
					sound.manager.masterVolume = easeOutQuad(t - startTime, startVolume, endVolume - startVolume, duration);
				} else {
					sound.manager.masterVolume = endVolume;
				}
				_isComplete = sound.manager.masterVolume == endVolume;

			} else {
				if(t - startTime < duration){
					sound.volume = easeOutQuad(t - startTime, startVolume, endVolume - startVolume, duration);
				} else {
					sound.volume = endVolume;
				}
				_isComplete = sound.volume == endVolume;
			}
			return _isComplete;

		}

		public function init(startVolume:Number, endVolume:Number, duration:Number):void {
			this.startTime = getTimer();
			this.startVolume = startVolume;
			this.endVolume = endVolume;
			this.duration = duration;
			_isComplete = false;
		}

		/**
		 * End the fade and dispatch ended signal. Optionally, apply the end volume as well.
		 * **/
		public function end(applyEndVolume:Boolean = false):void {
			_isComplete = true;
			if(!isMasterFade){
				if(applyEndVolume){
					sound.volume = endVolume;
				}
				if(stopAtZero && sound.volume == 0){
					sound.stop();
				}
			}
			ended && ended.call(this, this.sound);
			ended = null;
		}

		/** End the fade silently, will not send 'ended' signal **/
		public function kill():void {
			_isComplete = true;
			_sound = null;
			ended = null;
		}

		/**
		 * Equations from the man Robert Penner, see here for more:
		 * http://www.dzone.com/snippets/robert-penner-easing-equations
		 */
		protected static function easeOutQuad(position:Number, startValue:Number, change:Number, duration:Number):Number {
			return -change *(position/=duration)*(position-2) + startValue;
		};

		protected static function easeInOutQuad(position:Number, startValue:Number, change:Number, duration:Number):Number {
			if ((position/=duration/2) < 1){
				return change/2*position*position + startValue;
			}
			return -change/2 * ((--position)*(position-2) - 1) + startValue;
		}

		public function get isComplete():Boolean {
			return _isComplete;
		}

		public function get sound():SoundInstance { return _sound; }
		public function set sound(value:SoundInstance):void {
			_sound = value;
		}
	}
}
