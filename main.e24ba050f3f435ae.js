(self.webpackChunkinterface=self.webpackChunkinterface||[]).push([[179],{1223:(at,He,$)=>{"use strict";function Y(t){return"function"==typeof t}function ce(t){const e=t(i=>{Error.call(i),i.stack=(new Error).stack});return e.prototype=Object.create(Error.prototype),e.prototype.constructor=e,e}const z=ce(t=>function(e){t(this),this.message=e?`${e.length} errors occurred during unsubscription:\n${e.map((i,r)=>`${r+1}) ${i.toString()}`).join("\n  ")}`:"",this.name="UnsubscriptionError",this.errors=e});function b(t,n){if(t){const e=t.indexOf(n);0<=e&&t.splice(e,1)}}class w{constructor(n){this.initialTeardown=n,this.closed=!1,this._parentage=null,this._finalizers=null}unsubscribe(){let n;if(!this.closed){this.closed=!0;const{_parentage:e}=this;if(e)if(this._parentage=null,Array.isArray(e))for(const s of e)s.remove(this);else e.remove(this);const{initialTeardown:i}=this;if(Y(i))try{i()}catch(s){n=s instanceof z?s.errors:[s]}const{_finalizers:r}=this;if(r){this._finalizers=null;for(const s of r)try{x(s)}catch(a){n=n??[],a instanceof z?n=[...n,...a.errors]:n.push(a)}}if(n)throw new z(n)}}add(n){var e;if(n&&n!==this)if(this.closed)x(n);else{if(n instanceof w){if(n.closed||n._hasParent(this))return;n._addParent(this)}(this._finalizers=null!==(e=this._finalizers)&&void 0!==e?e:[]).push(n)}}_hasParent(n){const{_parentage:e}=this;return e===n||Array.isArray(e)&&e.includes(n)}_addParent(n){const{_parentage:e}=this;this._parentage=Array.isArray(e)?(e.push(n),e):e?[e,n]:n}_removeParent(n){const{_parentage:e}=this;e===n?this._parentage=null:Array.isArray(e)&&b(e,n)}remove(n){const{_finalizers:e}=this;e&&b(e,n),n instanceof w&&n._removeParent(this)}}w.EMPTY=(()=>{const t=new w;return t.closed=!0,t})();const g=w.EMPTY;function p(t){return t instanceof w||t&&"closed"in t&&Y(t.remove)&&Y(t.add)&&Y(t.unsubscribe)}function x(t){Y(t)?t():t.unsubscribe()}const T={onUnhandledError:null,onStoppedNotification:null,Promise:void 0,useDeprecatedSynchronousErrorHandling:!1,useDeprecatedNextContext:!1},E={setTimeout(t,n,...e){const{delegate:i}=E;return i?.setTimeout?i.setTimeout(t,n,...e):setTimeout(t,n,...e)},clearTimeout(t){const{delegate:n}=E;return(n?.clearTimeout||clearTimeout)(t)},delegate:void 0};function k(t){E.setTimeout(()=>{const{onUnhandledError:n}=T;if(!n)throw t;n(t)})}function F(){}const J=oe("C",void 0,void 0);function oe(t,n,e){return{kind:t,value:n,error:e}}let re=null;function Pe(t){if(T.useDeprecatedSynchronousErrorHandling){const n=!re;if(n&&(re={errorThrown:!1,error:null}),t(),n){const{errorThrown:e,error:i}=re;if(re=null,e)throw i}}else t()}class De extends w{constructor(n){super(),this.isStopped=!1,n?(this.destination=n,p(n)&&n.add(this)):this.destination=ve}static create(n,e,i){return new me(n,e,i)}next(n){this.isStopped?ge(function ee(t){return oe("N",t,void 0)}(n),this):this._next(n)}error(n){this.isStopped?ge(function R(t){return oe("E",void 0,t)}(n),this):(this.isStopped=!0,this._error(n))}complete(){this.isStopped?ge(J,this):(this.isStopped=!0,this._complete())}unsubscribe(){this.closed||(this.isStopped=!0,super.unsubscribe(),this.destination=null)}_next(n){this.destination.next(n)}_error(n){try{this.destination.error(n)}finally{this.unsubscribe()}}_complete(){try{this.destination.complete()}finally{this.unsubscribe()}}}const Ae=Function.prototype.bind;function Me(t,n){return Ae.call(t,n)}class he{constructor(n){this.partialObserver=n}next(n){const{partialObserver:e}=this;if(e.next)try{e.next(n)}catch(i){be(i)}}error(n){const{partialObserver:e}=this;if(e.error)try{e.error(n)}catch(i){be(i)}else be(n)}complete(){const{partialObserver:n}=this;if(n.complete)try{n.complete()}catch(e){be(e)}}}class me extends De{constructor(n,e,i){let r;if(super(),Y(n)||!n)r={next:n??void 0,error:e??void 0,complete:i??void 0};else{let s;this&&T.useDeprecatedNextContext?(s=Object.create(n),s.unsubscribe=()=>this.unsubscribe(),r={next:n.next&&Me(n.next,s),error:n.error&&Me(n.error,s),complete:n.complete&&Me(n.complete,s)}):r=n}this.destination=new he(r)}}function be(t){T.useDeprecatedSynchronousErrorHandling?function Re(t){T.useDeprecatedSynchronousErrorHandling&&re&&(re.errorThrown=!0,re.error=t)}(t):k(t)}function ge(t,n){const{onStoppedNotification:e}=T;e&&E.setTimeout(()=>e(t,n))}const ve={closed:!0,next:F,error:function _e(t){throw t},complete:F},K="function"==typeof Symbol&&Symbol.observable||"@@observable";function H(t){return t}function j(t){return 0===t.length?H:1===t.length?t[0]:function(e){return t.reduce((i,r)=>r(i),e)}}let te=(()=>{class t{constructor(e){e&&(this._subscribe=e)}lift(e){const i=new t;return i.source=this,i.operator=e,i}subscribe(e,i,r){const s=function ne(t){return t&&t instanceof De||function ae(t){return t&&Y(t.next)&&Y(t.error)&&Y(t.complete)}(t)&&p(t)}(e)?e:new me(e,i,r);return Pe(()=>{const{operator:a,source:o}=this;s.add(a?a.call(s,o):o?this._subscribe(s):this._trySubscribe(s))}),s}_trySubscribe(e){try{return this._subscribe(e)}catch(i){e.error(i)}}forEach(e,i){return new(i=W(i))((r,s)=>{const a=new me({next:o=>{try{e(o)}catch(c){s(c),a.unsubscribe()}},error:s,complete:r});this.subscribe(a)})}_subscribe(e){var i;return null===(i=this.source)||void 0===i?void 0:i.subscribe(e)}[K](){return this}pipe(...e){return j(e)(this)}toPromise(e){return new(e=W(e))((i,r)=>{let s;this.subscribe(a=>s=a,a=>r(a),()=>i(s))})}}return t.create=n=>new t(n),t})();function W(t){var n;return null!==(n=t??T.Promise)&&void 0!==n?n:Promise}const se=ce(t=>function(){t(this),this.name="ObjectUnsubscribedError",this.message="object unsubscribed"});let U=(()=>{class t extends te{constructor(){super(),this.closed=!1,this.currentObservers=null,this.observers=[],this.isStopped=!1,this.hasError=!1,this.thrownError=null}lift(e){const i=new S(this,this);return i.operator=e,i}_throwIfClosed(){if(this.closed)throw new se}next(e){Pe(()=>{if(this._throwIfClosed(),!this.isStopped){this.currentObservers||(this.currentObservers=Array.from(this.observers));for(const i of this.currentObservers)i.next(e)}})}error(e){Pe(()=>{if(this._throwIfClosed(),!this.isStopped){this.hasError=this.isStopped=!0,this.thrownError=e;const{observers:i}=this;for(;i.length;)i.shift().error(e)}})}complete(){Pe(()=>{if(this._throwIfClosed(),!this.isStopped){this.isStopped=!0;const{observers:e}=this;for(;e.length;)e.shift().complete()}})}unsubscribe(){this.isStopped=this.closed=!0,this.observers=this.currentObservers=null}get observed(){var e;return(null===(e=this.observers)||void 0===e?void 0:e.length)>0}_trySubscribe(e){return this._throwIfClosed(),super._trySubscribe(e)}_subscribe(e){return this._throwIfClosed(),this._checkFinalizedStatuses(e),this._innerSubscribe(e)}_innerSubscribe(e){const{hasError:i,isStopped:r,observers:s}=this;return i||r?g:(this.currentObservers=null,s.push(e),new w(()=>{this.currentObservers=null,b(s,e)}))}_checkFinalizedStatuses(e){const{hasError:i,thrownError:r,isStopped:s}=this;i?e.error(r):s&&e.complete()}asObservable(){const e=new te;return e.source=this,e}}return t.create=(n,e)=>new S(n,e),t})();class S extends U{constructor(n,e){super(),this.destination=n,this.source=e}next(n){var e,i;null===(i=null===(e=this.destination)||void 0===e?void 0:e.next)||void 0===i||i.call(e,n)}error(n){var e,i;null===(i=null===(e=this.destination)||void 0===e?void 0:e.error)||void 0===i||i.call(e,n)}complete(){var n,e;null===(e=null===(n=this.destination)||void 0===n?void 0:n.complete)||void 0===e||e.call(n)}_subscribe(n){var e,i;return null!==(i=null===(e=this.source)||void 0===e?void 0:e.subscribe(n))&&void 0!==i?i:g}}function le(t){return Y(t?.lift)}function Ue(t){return n=>{if(le(n))return n.lift(function(e){try{return t(e,this)}catch(i){this.error(i)}});throw new TypeError("Unable to lift unknown Observable type")}}function Ze(t,n,e,i,r){return new Q(t,n,e,i,r)}class Q extends De{constructor(n,e,i,r,s,a){super(n),this.onFinalize=s,this.shouldUnsubscribe=a,this._next=e?function(o){try{e(o)}catch(c){n.error(c)}}:super._next,this._error=r?function(o){try{r(o)}catch(c){n.error(c)}finally{this.unsubscribe()}}:super._error,this._complete=i?function(){try{i()}catch(o){n.error(o)}finally{this.unsubscribe()}}:super._complete}unsubscribe(){var n;if(!this.shouldUnsubscribe||this.shouldUnsubscribe()){const{closed:e}=this;super.unsubscribe(),!e&&(null===(n=this.onFinalize)||void 0===n||n.call(this))}}}function Le(t,n){return Ue((e,i)=>{let r=0;e.subscribe(Ze(i,s=>{i.next(t.call(n,s,r++))}))})}var ze=$(7582);const pe=t=>t&&"number"==typeof t.length&&"function"!=typeof t;function de(t){return Y(t?.then)}function ke(t){return Y(t[K])}function Xe(t){return Symbol.asyncIterator&&Y(t?.[Symbol.asyncIterator])}function We(t){return new TypeError(`You provided ${null!==t&&"object"==typeof t?"an invalid object":`'${t}'`} where a stream was expected. You can provide an Observable, Promise, ReadableStream, Array, AsyncIterable, or Iterable.`)}const st=function ct(){return"function"==typeof Symbol&&Symbol.iterator?Symbol.iterator:"@@iterator"}();function Je(t){return Y(t?.[st])}function ft(t){return(0,ze.__asyncGenerator)(this,arguments,function*(){const e=t.getReader();try{for(;;){const{value:i,done:r}=yield(0,ze.__await)(e.read());if(r)return yield(0,ze.__await)(void 0);yield yield(0,ze.__await)(i)}}finally{e.releaseLock()}})}function ot(t){return Y(t?.getReader)}function lt(t){if(t instanceof te)return t;if(null!=t){if(ke(t))return function ht(t){return new te(n=>{const e=t[K]();if(Y(e.subscribe))return e.subscribe(n);throw new TypeError("Provided object does not correctly implement Symbol.observable")})}(t);if(pe(t))return function Lt(t){return new te(n=>{for(let e=0;e<t.length&&!n.closed;e++)n.next(t[e]);n.complete()})}(t);if(de(t))return function $t(t){return new te(n=>{t.then(e=>{n.closed||(n.next(e),n.complete())},e=>n.error(e)).then(null,k)})}(t);if(Xe(t))return _t(t);if(Je(t))return function wt(t){return new te(n=>{for(const e of t)if(n.next(e),n.closed)return;n.complete()})}(t);if(ot(t))return function Mt(t){return _t(ft(t))}(t)}throw We(t)}function _t(t){return new te(n=>{(function L(t,n){var e,i,r,s;return(0,ze.__awaiter)(this,void 0,void 0,function*(){try{for(e=(0,ze.__asyncValues)(t);!(i=yield e.next()).done;)if(n.next(i.value),n.closed)return}catch(a){r={error:a}}finally{try{i&&!i.done&&(s=e.return)&&(yield s.call(e))}finally{if(r)throw r.error}}n.complete()})})(t,n).catch(e=>n.error(e))})}function N(t,n,e,i=0,r=!1){const s=n.schedule(function(){e(),r?t.add(this.schedule(null,i)):this.unsubscribe()},i);if(t.add(s),!r)return s}function Ne(t,n,e=1/0){return Y(n)?Ne((i,r)=>Le((s,a)=>n(i,s,r,a))(lt(t(i,r))),e):("number"==typeof n&&(e=n),Ue((i,r)=>function X(t,n,e,i,r,s,a,o){const c=[];let l=0,u=0,d=!1;const h=()=>{d&&!c.length&&!l&&n.complete()},y=D=>l<i?I(D):c.push(D),I=D=>{s&&n.next(D),l++;let V=!1;lt(e(D,u++)).subscribe(Ze(n,we=>{r?.(we),s?y(we):n.next(we)},()=>{V=!0},void 0,()=>{if(V)try{for(l--;c.length&&l<i;){const we=c.shift();a?N(n,a,()=>I(we)):I(we)}h()}catch(we){n.error(we)}}))};return t.subscribe(Ze(n,y,()=>{d=!0,h()})),()=>{o?.()}}(i,r,t,e)))}function Be(t=1/0){return Ne(H,t)}const pt=new te(t=>t.complete());function Mn(t){return t&&Y(t.schedule)}function rn(t){return t[t.length-1]}function Qt(t){return Y(rn(t))?t.pop():void 0}function Zn(t){return Mn(rn(t))?t.pop():void 0}function er(t,n=0){return Ue((e,i)=>{e.subscribe(Ze(i,r=>N(i,t,()=>i.next(r),n),()=>N(i,t,()=>i.complete(),n),r=>N(i,t,()=>i.error(r),n)))})}function O1(t,n=0){return Ue((e,i)=>{i.add(t.schedule(()=>e.subscribe(i),n))})}function dr(t,n){if(!t)throw new Error("Iterable cannot be null");return new te(e=>{N(e,n,()=>{const i=t[Symbol.asyncIterator]();N(e,n,()=>{i.next().then(r=>{r.done?e.complete():e.next(r.value)})},0,!0)})})}function ti(t,n){return n?function Wt(t,n){if(null!=t){if(ke(t))return function Ui(t,n){return lt(t).pipe(O1(n),er(n))}(t,n);if(pe(t))return function Yn(t,n){return new te(e=>{let i=0;return n.schedule(function(){i===t.length?e.complete():(e.next(t[i++]),e.closed||this.schedule())})})}(t,n);if(de(t))return function Yt(t,n){return lt(t).pipe(O1(n),er(n))}(t,n);if(Xe(t))return dr(t,n);if(Je(t))return function tr(t,n){return new te(e=>{let i;return N(e,n,()=>{i=t[st](),N(e,n,()=>{let r,s;try{({value:r,done:s}=i.next())}catch(a){return void e.error(a)}s?e.complete():e.next(r)},0,!0)}),()=>Y(i?.return)&&i.return()})}(t,n);if(ot(t))return function v2(t,n){return dr(ft(t),n)}(t,n)}throw We(t)}(t,n):lt(t)}function n1(...t){const n=Zn(t),e=function mr(t,n){return"number"==typeof rn(t)?t.pop():n}(t,1/0),i=t;return i.length?1===i.length?lt(i[0]):Be(e)(ti(i,n)):pt}class Vn extends U{constructor(n){super(),this._value=n}get value(){return this.getValue()}_subscribe(n){const e=super._subscribe(n);return!e.closed&&n.next(this._value),e}getValue(){const{hasError:n,thrownError:e,_value:i}=this;if(n)throw e;return this._throwIfClosed(),i}next(n){super.next(this._value=n)}}function ln(...t){return ti(t,Zn(t))}function H1(t={}){const{connector:n=(()=>new U),resetOnError:e=!0,resetOnComplete:i=!0,resetOnRefCountZero:r=!0}=t;return s=>{let a,o,c,l=0,u=!1,d=!1;const h=()=>{o?.unsubscribe(),o=void 0},y=()=>{h(),a=c=void 0,u=d=!1},I=()=>{const D=a;y(),D?.unsubscribe()};return Ue((D,V)=>{l++,!d&&!u&&h();const we=c=c??n();V.add(()=>{l--,0===l&&!d&&!u&&(o=Qe(I,r))}),we.subscribe(V),!a&&l>0&&(a=new me({next:Ce=>we.next(Ce),error:Ce=>{d=!0,h(),o=Qe(y,e,Ce),we.error(Ce)},complete:()=>{u=!0,h(),o=Qe(y,i),we.complete()}}),lt(D).subscribe(a))})(s)}}function Qe(t,n,...e){if(!0===n)return void t();if(!1===n)return;const i=new me({next:()=>{i.unsubscribe(),t()}});return lt(n(...e)).subscribe(i)}function vi(t,n){return Ue((e,i)=>{let r=null,s=0,a=!1;const o=()=>a&&!r&&i.complete();e.subscribe(Ze(i,c=>{r?.unsubscribe();let l=0;const u=s++;lt(t(c,u)).subscribe(r=Ze(i,d=>i.next(n?n(c,d,u,l++):d),()=>{r=null,o()}))},()=>{a=!0,o()}))})}function r1(t,n=H){return t=t??gr,Ue((e,i)=>{let r,s=!0;e.subscribe(Ze(i,a=>{const o=n(a);(s||!t(r,o))&&(s=!1,r=o,i.next(a))}))})}function gr(t,n){return t===n}function An(t){for(let n in t)if(t[n]===An)return n;throw Error("Could not find renamed property on target object.")}function yo(t,n){for(const e in n)n.hasOwnProperty(e)&&!t.hasOwnProperty(e)&&(t[e]=n[e])}function ni(t){if("string"==typeof t)return t;if(Array.isArray(t))return"["+t.map(ni).join(", ")+"]";if(null==t)return""+t;if(t.overriddenName)return`${t.overriddenName}`;if(t.name)return`${t.name}`;const n=t.toString();if(null==n)return""+n;const e=n.indexOf("\n");return-1===e?n:n.substring(0,e)}function nr(t,n){return null==t||""===t?null===n?"":n:null==n||""===n?t:t+" "+n}const y2=An({__forward_ref__:An});function _n(t){return t.__forward_ref__=_n,t.toString=function(){return ni(this())},t}function fn(t){return _o(t)?t():t}function _o(t){return"function"==typeof t&&t.hasOwnProperty(y2)&&t.__forward_ref__===_n}function bo(t){return t&&!!t.\u0275providers}const s1="https://g.co/ng/security#xss";class kt extends Error{constructor(n,e){super(function Wa(t,n){return`NG0${Math.abs(t)}${n?": "+n:""}`}(n,e)),this.code=n}}function Bn(t){return"string"==typeof t?t:null==t?"":String(t)}function Zc(t,n){throw new kt(-201,!1)}function wo(t,n){null==t&&function Kn(t,n,e,i){throw new Error(`ASSERTION ERROR: ${t}`+(null==i?"":` [Expected=> ${e} ${i} ${n} <=Actual]`))}(n,t,null,"!=")}function Pt(t){return{token:t.token,providedIn:t.providedIn||null,factory:t.factory,value:void 0}}function oi(t){return{providers:t.providers||[],imports:t.imports||[]}}function $u(t){return z7(t,Wu)||z7(t,O7)}function z7(t,n){return t.hasOwnProperty(n)?t[n]:null}function ju(t){return t&&(t.hasOwnProperty(z5)||t.hasOwnProperty(lw))?t[z5]:null}const Wu=An({\u0275prov:An}),z5=An({\u0275inj:An}),O7=An({ngInjectableDef:An}),lw=An({ngInjectorDef:An});var Mi=function(t){return t[t.Default=0]="Default",t[t.Host=1]="Host",t[t.Self=2]="Self",t[t.SkipSelf=4]="SkipSelf",t[t.Optional=8]="Optional",t}(Mi||{});let O5;function Ma(t){const n=O5;return O5=t,n}function V7(t,n,e){const i=$u(t);return i&&"root"==i.providedIn?void 0===i.value?i.value=i.factory():i.value:e&Mi.Optional?null:void 0!==n?n:void Zc(ni(t))}const Mr=globalThis;class Jt{constructor(n,e){this._desc=n,this.ngMetadataName="InjectionToken",this.\u0275prov=void 0,"number"==typeof e?this.__NG_ELEMENT_ID__=e:void 0!==e&&(this.\u0275prov=Pt({token:this,providedIn:e.providedIn||"root",factory:e.factory}))}get multi(){return this}toString(){return`InjectionToken ${this._desc}`}}const F0={},U5="__NG_DI_FLAG__",Yc="ngTempTokenPath",$5=/\n/gm,B7="__source";let Kc;function Q2(t){const n=Kc;return Kc=t,n}function qu(t,n=Mi.Default){if(void 0===Kc)throw new kt(-203,!1);return null===Kc?V7(t,void 0,n):Kc.get(t,n&Mi.Optional?null:void 0,n)}function gt(t,n=Mi.Default){return(function H7(){return O5}()||qu)(fn(t),n)}function Kt(t,n=Mi.Default){return gt(t,U0(n))}function U0(t){return typeof t>"u"||"number"==typeof t?t:0|(t.optional&&8)|(t.host&&1)|(t.self&&2)|(t.skipSelf&&4)}function W5(t){const n=[];for(let e=0;e<t.length;e++){const i=fn(t[e]);if(Array.isArray(i)){if(0===i.length)throw new kt(900,!1);let r,s=Mi.Default;for(let a=0;a<i.length;a++){const o=i[a],c=Gu(o);"number"==typeof c?-1===c?r=o.token:s|=c:r=o}n.push(gt(r,s))}else n.push(gt(i))}return n}function $0(t,n){return t[U5]=n,t.prototype[U5]=n,t}function Gu(t){return t[U5]}function b2(t){return{toString:t}.toString()}var Zu=function(t){return t[t.OnPush=0]="OnPush",t[t.Default=1]="Default",t}(Zu||{}),Co=function(t){return t[t.Emulated=0]="Emulated",t[t.None=2]="None",t[t.ShadowDom=3]="ShadowDom",t}(Co||{});const V1={},$i=[],Yu=An({\u0275cmp:An}),q5=An({\u0275dir:An}),G5=An({\u0275pipe:An}),U7=An({\u0275mod:An}),w2=An({\u0275fac:An}),j0=An({__NG_ELEMENT_ID__:An}),$7=An({__NG_ENV_ID__:An});function j7(t,n,e){let i=t.length;for(;;){const r=t.indexOf(n,e);if(-1===r)return r;if(0===r||t.charCodeAt(r-1)<=32){const s=n.length;if(r+s===i||t.charCodeAt(r+s)<=32)return r}e=r+1}}function Z5(t,n,e){let i=0;for(;i<e.length;){const r=e[i];if("number"==typeof r){if(0!==r)break;i++;const s=e[i++],a=e[i++],o=e[i++];t.setAttribute(n,a,o,s)}else{const s=r,a=e[++i];q7(s)?t.setProperty(n,s,a):t.setAttribute(n,s,a),i++}}return i}function W7(t){return 3===t||4===t||6===t}function q7(t){return 64===t.charCodeAt(0)}function W0(t,n){if(null!==n&&0!==n.length)if(null===t||0===t.length)t=n.slice();else{let e=-1;for(let i=0;i<n.length;i++){const r=n[i];"number"==typeof r?e=r:0===e||G7(t,e,r,null,-1===e||2===e?n[++i]:null)}}return t}function G7(t,n,e,i,r){let s=0,a=t.length;if(-1===n)a=-1;else for(;s<t.length;){const o=t[s++];if("number"==typeof o){if(o===n){a=-1;break}if(o>n){a=s-1;break}}}for(;s<t.length;){const o=t[s];if("number"==typeof o)break;if(o===e){if(null===i)return void(null!==r&&(t[s+1]=r));if(i===t[s+1])return void(t[s+2]=r)}s++,null!==i&&s++,null!==r&&s++}-1!==a&&(t.splice(a,0,n),s=a+1),t.splice(s++,0,e),null!==i&&t.splice(s++,0,i),null!==r&&t.splice(s++,0,r)}const Z7="ng-template";function hw(t,n,e){let i=0,r=!0;for(;i<t.length;){let s=t[i++];if("string"==typeof s&&r){const a=t[i++];if(e&&"class"===s&&-1!==j7(a.toLowerCase(),n,0))return!0}else{if(1===s){for(;i<t.length&&"string"==typeof(s=t[i++]);)if(s.toLowerCase()===n)return!0;return!1}"number"==typeof s&&(r=!1)}}return!1}function Y7(t){return 4===t.type&&t.value!==Z7}function Y5(t,n,e){return n===(4!==t.type||e?t.value:Z7)}function pw(t,n,e){let i=4;const r=t.attrs||[],s=function qa(t){for(let n=0;n<t.length;n++)if(W7(t[n]))return n;return t.length}(r);let a=!1;for(let o=0;o<n.length;o++){const c=n[o];if("number"!=typeof c){if(!a)if(4&i){if(i=2|1&i,""!==c&&!Y5(t,c,e)||""===c&&1===n.length){if(qs(i))return!1;a=!0}}else{const l=8&i?c:n[++o];if(8&i&&null!==t.attrs){if(!hw(t.attrs,l,e)){if(qs(i))return!1;a=!0}continue}const d=o1(8&i?"class":c,r,Y7(t),e);if(-1===d){if(qs(i))return!1;a=!0;continue}if(""!==l){let h;h=d>s?"":r[d+1].toLowerCase();const y=8&i?h:null;if(y&&-1!==j7(y,l,0)||2&i&&l!==h){if(qs(i))return!1;a=!0}}}}else{if(!a&&!qs(i)&&!qs(c))return!1;if(a&&qs(c))continue;a=!1,i=c|1&i}}return qs(i)||a}function qs(t){return 0==(1&t)}function o1(t,n,e,i){if(null===n)return-1;let r=0;if(i||!e){let s=!1;for(;r<n.length;){const a=n[r];if(a===t)return r;if(3===a||6===a)s=!0;else{if(1===a||2===a){let o=n[++r];for(;"string"==typeof o;)o=n[++r];continue}if(4===a)break;if(0===a){r+=4;continue}}r+=s?1:2}return-1}return function Gs(t,n){let e=t.indexOf(4);if(e>-1)for(e++;e<t.length;){const i=t[e];if("number"==typeof i)return-1;if(i===n)return e;e++}return-1}(n,t)}function ir(t,n,e=!1){for(let i=0;i<n.length;i++)if(pw(t,n[i],e))return!0;return!1}function gw(t,n){e:for(let e=0;e<n.length;e++){const i=n[e];if(t.length===i.length){for(let r=0;r<t.length;r++)if(t[r]!==i[r])continue e;return!0}}return!1}function q0(t,n){return t?":not("+n.trim()+")":n}function Qc(t){let n=t[0],e=1,i=2,r="",s=!1;for(;e<t.length;){let a=t[e];if("string"==typeof a)if(2&i){const o=t[++e];r+="["+a+(o.length>0?'="'+o+'"':"")+"]"}else 8&i?r+="."+a:4&i&&(r+=" "+a);else""!==r&&!qs(a)&&(n+=q0(s,r),r=""),i=a,s=s||!qs(i);e++}return""!==r&&(n+=q0(s,r)),n}function Nt(t){return b2(()=>{const n=Sa(t),e={...n,decls:t.decls,vars:t.vars,template:t.template,consts:t.consts||null,ngContentSelectors:t.ngContentSelectors,onPush:t.changeDetection===Zu.OnPush,directiveDefs:null,pipeDefs:null,dependencies:n.standalone&&t.dependencies||null,getStandaloneInjector:null,signals:t.signals??!1,data:t.data||{},encapsulation:t.encapsulation||Co.Emulated,styles:t.styles||$i,_:null,schemas:t.schemas||null,tView:null,id:""};K5(e);const i=t.dependencies;return e.directiveDefs=Ku(i,!1),e.pipeDefs=Ku(i,!0),e.id=function G0(t){let n=0;const e=[t.selectors,t.ngContentSelectors,t.hostVars,t.hostAttrs,t.consts,t.vars,t.decls,t.encapsulation,t.standalone,t.signals,t.exportAs,JSON.stringify(t.inputs),JSON.stringify(t.outputs),Object.getOwnPropertyNames(t.type.prototype),!!t.contentQueries,!!t.viewQuery].join("|");for(const r of e)n=Math.imul(31,n)+r.charCodeAt(0)<<0;return n+=2147483648,"c"+n}(e),e})}function c1(t){return Si(t)||is(t)}function ka(t){return null!==t}function li(t){return b2(()=>({type:t.type,bootstrap:t.bootstrap||$i,declarations:t.declarations||$i,imports:t.imports||$i,exports:t.exports||$i,transitiveCompileScopes:null,schemas:t.schemas||null,id:t.id||null}))}function l1(t,n){if(null==t)return V1;const e={};for(const i in t)if(t.hasOwnProperty(i)){let r=t[i],s=r;Array.isArray(r)&&(s=r[1],r=r[0]),e[r]=i,n&&(n[r]=s)}return e}function zt(t){return b2(()=>{const n=Sa(t);return K5(n),n})}function vn(t){return{type:t.type,name:t.name,factory:null,pure:!1!==t.pure,standalone:!0===t.standalone,onDestroy:t.type.prototype.ngOnDestroy||null}}function Si(t){return t[Yu]||null}function is(t){return t[q5]||null}function la(t){return t[G5]||null}function Ga(t,n){const e=t[U7]||null;if(!e&&!0===n)throw new Error(`Type ${ni(t)} does not have '\u0275mod' property.`);return e}function Sa(t){const n={};return{type:t.type,providersResolver:null,factory:null,hostBindings:t.hostBindings||null,hostVars:t.hostVars||0,hostAttrs:t.hostAttrs||null,contentQueries:t.contentQueries||null,declaredInputs:n,inputTransforms:null,inputConfig:t.inputs||V1,exportAs:t.exportAs||null,standalone:!0===t.standalone,signals:!0===t.signals,selectors:t.selectors||$i,viewQuery:t.viewQuery||null,features:t.features||null,setInput:null,findHostDirectiveDefs:null,hostDirectives:null,inputs:l1(t.inputs,n),outputs:l1(t.outputs)}}function K5(t){t.features?.forEach(n=>n(t))}function Ku(t,n){if(!t)return null;const e=n?la:c1;return()=>("function"==typeof t?t():t).map(i=>e(i)).filter(ka)}const Kr=0,hn=1,ui=2,fr=3,Ts=4,Z0=5,Xr=6,da=7,rs=8,Ea=9,fa=10,ii=11,el=12,tl=13,f3=14,Lr=15,u1=16,h3=17,F1=18,J2=19,X7=20,x2=21,Za=22,Y0=23,Xu=24,Ei=25,Q7=1,_w=2,T2=7,nl=9,Zs=11;function Ya(t){return Array.isArray(t)&&"object"==typeof t[Q7]}function Aa(t){return Array.isArray(t)&&!0===t[Q7]}function J7(t){return 0!=(4&t.flags)}function p3(t){return t.componentOffset>-1}function ec(t){return 1==(1&t.flags)}function Ia(t){return!!t.template}function e6(t){return 0!=(512&t[ui])}function xo(t,n){return t.hasOwnProperty(w2)?t[w2]:null}let Ps=null,Ka=!1;function Pr(t){const n=Ps;return Ps=t,n}const ef={version:0,dirty:!1,producerNode:void 0,producerLastReadVersion:void 0,producerIndexOfThis:void 0,nextProducerIndex:0,liveConsumerNode:void 0,liveConsumerIndexOfThis:void 0,consumerAllowSignalWrites:!1,consumerIsAlwaysLive:!1,producerMustRecompute:()=>!1,producerRecomputeValue:()=>{},consumerMarkedDirty:()=>{}};function nc(t){if(!U1(t)||t.dirty){if(!t.producerMustRecompute(t)&&!am(t))return void(t.dirty=!1);t.producerRecomputeValue(t),t.dirty=!1}}function To(t){t.dirty=!0,function d1(t){if(void 0===t.liveConsumerNode)return;const n=Ka;Ka=!0;try{for(const e of t.liveConsumerNode)e.dirty||To(e)}finally{Ka=n}}(t),t.consumerMarkedDirty?.(t)}function Ys(t){return t&&(t.nextProducerIndex=0),Pr(t)}function nf(t,n){if(Pr(n),t&&void 0!==t.producerNode&&void 0!==t.producerIndexOfThis&&void 0!==t.producerLastReadVersion){if(U1(t))for(let e=t.nextProducerIndex;e<t.producerNode.length;e++)g3(t.producerNode[e],t.producerIndexOfThis[e]);for(;t.producerNode.length>t.nextProducerIndex;)t.producerNode.pop(),t.producerLastReadVersion.pop(),t.producerIndexOfThis.pop()}}function am(t){v3(t);for(let n=0;n<t.producerNode.length;n++){const e=t.producerNode[n],i=t.producerLastReadVersion[n];if(i!==e.version||(nc(e),i!==e.version))return!0}return!1}function X0(t){if(v3(t),U1(t))for(let n=0;n<t.producerNode.length;n++)g3(t.producerNode[n],t.producerIndexOfThis[n]);t.producerNode.length=t.producerLastReadVersion.length=t.producerIndexOfThis.length=0,t.liveConsumerNode&&(t.liveConsumerNode.length=t.liveConsumerIndexOfThis.length=0)}function g3(t,n){if(function Mo(t){t.liveConsumerNode??=[],t.liveConsumerIndexOfThis??=[]}(t),v3(t),1===t.liveConsumerNode.length)for(let i=0;i<t.producerNode.length;i++)g3(t.producerNode[i],t.producerIndexOfThis[i]);const e=t.liveConsumerNode.length-1;if(t.liveConsumerNode[n]=t.liveConsumerNode[e],t.liveConsumerIndexOfThis[n]=t.liveConsumerIndexOfThis[e],t.liveConsumerNode.length--,t.liveConsumerIndexOfThis.length--,n<t.liveConsumerNode.length){const i=t.liveConsumerIndexOfThis[n],r=t.liveConsumerNode[n];v3(r),r.producerIndexOfThis[i]=n}}function U1(t){return t.consumerIsAlwaysLive||(t?.liveConsumerNode?.length??0)>0}function v3(t){t.producerNode??=[],t.producerIndexOfThis??=[],t.producerLastReadVersion??=[]}let sl=null;const hm=()=>{},ol=(()=>({...ef,consumerIsAlwaysLive:!0,consumerAllowSignalWrites:!1,consumerMarkedDirty:t=>{t.schedule(t.ref)},hasRun:!1,cleanupFn:hm}))();class kw{constructor(n,e,i){this.previousValue=n,this.currentValue=e,this.firstChange=i}isFirstChange(){return this.firstChange}}function Un(){return J0}function J0(t){return t.type.prototype.ngOnChanges&&(t.setInput=e4),Sw}function Sw(){const t=pm(this),n=t?.current;if(n){const e=t.previous;if(e===V1)t.previous=n;else for(let i in n)e[i]=n[i];t.current=null,this.ngOnChanges(n)}}function e4(t,n,e,i){const r=this.declaredInputs[e],s=pm(t)||function ic(t,n){return t[E2]=n}(t,{previous:V1,current:null}),a=s.current||(s.current={}),o=s.previous,c=o[r];a[r]=new kw(c&&c.currentValue,n,o===V1),t[i]=n}Un.ngInherit=!0;const E2="__ngSimpleChanges__";function pm(t){return t[E2]||null}const ko=function(t,n,e){},cl="svg";function rr(t){for(;Array.isArray(t);)t=t[Kr];return t}function r6(t,n){return rr(n[t])}function ha(t,n){return rr(n[t.index])}function $1(t,n){return t.data[n]}function _3(t,n){return t[n]}function Ks(t,n){const e=n[t];return Ya(e)?e:e[Kr]}function Da(t,n){return null==n?null:t[n]}function gm(t){t[h3]=0}function cf(t){1024&t[ui]||(t[ui]|=1024,ul(t,1))}function a6(t){1024&t[ui]&&(t[ui]&=-1025,ul(t,-1))}function ul(t,n){let e=t[fr];if(null===e)return;e[Z0]+=n;let i=e;for(e=e[fr];null!==e&&(1===n&&1===i[Z0]||-1===n&&0===i[Z0]);)e[Z0]+=n,i=e,e=e[fr]}const Nn={lFrame:wm(null),bindingsEnabled:!0,skipHydrationRootTNode:null};function j1(){return Nn.bindingsEnabled}function w3(){return null!==Nn.skipHydrationRootTNode}function Ot(){return Nn.lFrame.lView}function Ri(){return Nn.lFrame.tView}function je(t){return Nn.lFrame.contextLView=t,t[rs]}function $e(t){return Nn.lFrame.contextLView=null,t}function zs(){let t=l6();for(;null!==t&&64===t.type;)t=t.parent;return t}function l6(){return Nn.lFrame.currentTNode}function q1(t,n){const e=Nn.lFrame;e.currentTNode=t,e.isParent=n}function t4(){return Nn.lFrame.isParent}function ac(){Nn.lFrame.isParent=!1}function pa(){const t=Nn.lFrame;let n=t.bindingRootIndex;return-1===n&&(n=t.bindingRootIndex=t.tView.bindingStartIndex),n}function Na(){return Nn.lFrame.bindingIndex}function C3(){return Nn.lFrame.bindingIndex++}function f1(t){const n=Nn.lFrame,e=n.bindingIndex;return n.bindingIndex=n.bindingIndex+t,e}function uf(t,n){const e=Nn.lFrame;e.bindingIndex=e.bindingRootIndex=t,df(n)}function df(t){Nn.lFrame.currentDirectiveIndex=t}function I2(t){const n=Nn.lFrame.currentDirectiveIndex;return-1===n?null:t[n]}function h1(){return Nn.lFrame.currentQueryIndex}function ff(t){Nn.lFrame.currentQueryIndex=t}function oc(t){const n=t[hn];return 2===n.type?n.declTNode:1===n.type?t[Xr]:null}function So(t,n,e){if(e&Mi.SkipSelf){let r=n,s=t;for(;!(r=r.parent,null!==r||e&Mi.Host||(r=oc(s),null===r||(s=s[f3],10&r.type))););if(null===r)return!1;n=r,t=s}const i=Nn.lFrame=bm();return i.currentTNode=n,i.lView=t,!0}function hf(t){const n=bm(),e=t[hn];Nn.lFrame=n,n.currentTNode=e.firstChild,n.lView=t,n.tView=e,n.contextLView=t,n.bindingIndex=e.bindingStartIndex,n.inI18n=!1}function bm(){const t=Nn.lFrame,n=null===t?null:t.child;return null===n?wm(t):n}function wm(t){const n={currentTNode:null,isParent:!0,lView:null,tView:null,selectedIndex:-1,contextLView:null,elementDepthCount:0,currentNamespace:null,currentDirectiveIndex:-1,bindingRootIndex:-1,bindingIndex:-1,currentQueryIndex:0,parent:t,child:null,inI18n:!1};return null!==t&&(t.child=n),n}function i4(){const t=Nn.lFrame;return Nn.lFrame=t.parent,t.currentTNode=null,t.lView=null,t}const cc=i4;function pf(){const t=i4();t.isParent=!0,t.tView=null,t.selectedIndex=-1,t.contextLView=null,t.elementDepthCount=0,t.currentDirectiveIndex=-1,t.currentNamespace=null,t.bindingRootIndex=-1,t.bindingIndex=-1,t.currentQueryIndex=0}function ma(){return Nn.lFrame.selectedIndex}function Ms(t){Nn.lFrame.selectedIndex=t}function ki(){const t=Nn.lFrame;return $1(t.tView,t.selectedIndex)}function Rt(){Nn.lFrame.currentNamespace=cl}function In(){!function Rw(){Nn.lFrame.currentNamespace=null}()}let Tm=!0;function M3(){return Tm}function ie(t){Tm=t}function q(t,n){for(let e=n.directiveStart,i=n.directiveEnd;e<i;e++){const s=t.data[e].type.prototype,{ngAfterContentInit:a,ngAfterContentChecked:o,ngAfterViewInit:c,ngAfterViewChecked:l,ngOnDestroy:u}=s;a&&(t.contentHooks??=[]).push(-e,a),o&&((t.contentHooks??=[]).push(e,o),(t.contentCheckHooks??=[]).push(e,o)),c&&(t.viewHooks??=[]).push(-e,c),l&&((t.viewHooks??=[]).push(e,l),(t.viewCheckHooks??=[]).push(e,l)),null!=u&&(t.destroyHooks??=[]).push(e,u)}}function fe(t,n,e){Ie(t,n,3,e)}function xe(t,n,e,i){(3&t[ui])===e&&Ie(t,n,e,i)}function G(t,n){let e=t[ui];(3&e)===n&&(e&=8191,e+=1,t[ui]=e)}function Ie(t,n,e,i){const s=i??-1,a=n.length-1;let o=0;for(let c=void 0!==i?65535&t[h3]:0;c<a;c++)if("number"==typeof n[c+1]){if(o=n[c],null!=i&&o>=i)break}else n[c]<0&&(t[h3]+=65536),(o<s||-1==s)&&(nn(t,e,n,c),t[h3]=(4294901760&t[h3])+c+2),c++}function Ye(t,n){ko(4,t,n);const e=Pr(null);try{n.call(t)}finally{Pr(e),ko(5,t,n)}}function nn(t,n,e,i){const r=e[i]<0,s=e[i+1],o=t[r?-e[i]:e[i]];r?t[ui]>>13<t[h3]>>16&&(3&t[ui])===n&&(t[ui]+=8192,Ye(o,s)):Ye(o,s)}const yi=-1;class Wi{constructor(n,e,i){this.factory=n,this.resolving=!1,this.canSeeViewProviders=e,this.injectImpl=i}}function Os(t){return t!==yi}function Vr(t){return 32767&t}function mf(t,n){let e=function Y1(t){return t>>16}(t),i=n;for(;e>0;)i=i[f3],e--;return i}let Lw=!0;function Mm(t){const n=Lw;return Lw=t,n}const oL=255,cL=5;let H2e=0;const uc={};function km(t,n){const e=lL(t,n);if(-1!==e)return e;const i=n[hn];i.firstCreatePass&&(t.injectorIndex=n.length,Pw(i.data,t),Pw(n,null),Pw(i.blueprint,null));const r=Sm(t,n),s=t.injectorIndex;if(Os(r)){const a=Vr(r),o=mf(r,n),c=o[hn].data;for(let l=0;l<8;l++)n[s+l]=o[a+l]|c[a+l]}return n[s+8]=r,s}function Pw(t,n){t.push(0,0,0,0,0,0,0,0,n)}function lL(t,n){return-1===t.injectorIndex||t.parent&&t.parent.injectorIndex===t.injectorIndex||null===n[t.injectorIndex+8]?-1:t.injectorIndex}function Sm(t,n){if(t.parent&&-1!==t.parent.injectorIndex)return t.parent.injectorIndex;let e=0,i=null,r=n;for(;null!==r;){if(i=gL(r),null===i)return yi;if(e++,r=r[f3],-1!==i.injectorIndex)return i.injectorIndex|e<<16}return yi}function zw(t,n,e){!function V2e(t,n,e){let i;"string"==typeof e?i=e.charCodeAt(0)||0:e.hasOwnProperty(j0)&&(i=e[j0]),null==i&&(i=e[j0]=H2e++);const r=i&oL;n.data[t+(r>>cL)]|=1<<r}(t,n,e)}function uL(t,n,e){if(e&Mi.Optional||void 0!==t)return t;Zc()}function dL(t,n,e,i){if(e&Mi.Optional&&void 0===i&&(i=null),!(e&(Mi.Self|Mi.Host))){const r=t[Ea],s=Ma(void 0);try{return r?r.get(n,i,e&Mi.Optional):V7(n,i,e&Mi.Optional)}finally{Ma(s)}}return uL(i,0,e)}function fL(t,n,e,i=Mi.Default,r){if(null!==t){if(2048&n[ui]&&!(i&Mi.Self)){const a=function W2e(t,n,e,i,r){let s=t,a=n;for(;null!==s&&null!==a&&2048&a[ui]&&!(512&a[ui]);){const o=hL(s,a,e,i|Mi.Self,uc);if(o!==uc)return o;let c=s.parent;if(!c){const l=a[X7];if(l){const u=l.get(e,uc,i);if(u!==uc)return u}c=gL(a),a=a[f3]}s=c}return r}(t,n,e,i,uc);if(a!==uc)return a}const s=hL(t,n,e,i,uc);if(s!==uc)return s}return dL(n,e,i,r)}function hL(t,n,e,i,r){const s=function U2e(t){if("string"==typeof t)return t.charCodeAt(0)||0;const n=t.hasOwnProperty(j0)?t[j0]:void 0;return"number"==typeof n?n>=0?n&oL:j2e:n}(e);if("function"==typeof s){if(!So(n,t,i))return i&Mi.Host?uL(r,0,i):dL(n,e,i,r);try{let a;if(a=s(i),null!=a||i&Mi.Optional)return a;Zc()}finally{cc()}}else if("number"==typeof s){let a=null,o=lL(t,n),c=yi,l=i&Mi.Host?n[Lr][Xr]:null;for((-1===o||i&Mi.SkipSelf)&&(c=-1===o?Sm(t,n):n[o+8],c!==yi&&mL(i,!1)?(a=n[hn],o=Vr(c),n=mf(c,n)):o=-1);-1!==o;){const u=n[hn];if(pL(s,o,u.data)){const d=B2e(o,n,e,a,i,l);if(d!==uc)return d}c=n[o+8],c!==yi&&mL(i,n[hn].data[o+8]===l)&&pL(s,o,n)?(a=u,o=Vr(c),n=mf(c,n)):o=-1}}return r}function B2e(t,n,e,i,r,s){const a=n[hn],o=a.data[t+8],u=Em(o,a,e,null==i?p3(o)&&Lw:i!=a&&0!=(3&o.type),r&Mi.Host&&s===o);return null!==u?s4(n,a,u,o):uc}function Em(t,n,e,i,r){const s=t.providerIndexes,a=n.data,o=1048575&s,c=t.directiveStart,u=s>>20,h=r?o+u:t.directiveEnd;for(let y=i?o:o+u;y<h;y++){const I=a[y];if(y<c&&e===I||y>=c&&I.type===e)return y}if(r){const y=a[c];if(y&&Ia(y)&&y.type===e)return c}return null}function s4(t,n,e,i){let r=t[e];const s=n.data;if(function ji(t){return t instanceof Wi}(r)){const a=r;a.resolving&&function O0(t,n){const e=n?`. Dependency path: ${n.join(" > ")} > ${t}`:"";throw new kt(-200,`Circular dependency in DI detected for ${t}${e}`)}(function Ni(t){return"function"==typeof t?t.name||t.toString():"object"==typeof t&&null!=t&&"function"==typeof t.type?t.type.name||t.type.toString():Bn(t)}(s[e]));const o=Mm(a.canSeeViewProviders);a.resolving=!0;const l=a.injectImpl?Ma(a.injectImpl):null;So(t,i,Mi.Default);try{r=t[e]=a.factory(void 0,s,t,i),n.firstCreatePass&&e>=i.directiveStart&&function M(t,n,e){const{ngOnChanges:i,ngOnInit:r,ngDoCheck:s}=n.type.prototype;if(i){const a=J0(n);(e.preOrderHooks??=[]).push(t,a),(e.preOrderCheckHooks??=[]).push(t,a)}r&&(e.preOrderHooks??=[]).push(0-t,r),s&&((e.preOrderHooks??=[]).push(t,s),(e.preOrderCheckHooks??=[]).push(t,s))}(e,s[e],n)}finally{null!==l&&Ma(l),Mm(o),a.resolving=!1,cc()}}return r}function pL(t,n,e){return!!(e[n+(t>>cL)]&1<<t)}function mL(t,n){return!(t&Mi.Self||t&Mi.Host&&n)}class to{constructor(n,e){this._tNode=n,this._lView=e}get(n,e,i){return fL(this._tNode,this._lView,n,U0(i),e)}}function j2e(){return new to(zs(),Ot())}function Di(t){return b2(()=>{const n=t.prototype.constructor,e=n[w2]||Ow(n),i=Object.prototype;let r=Object.getPrototypeOf(t.prototype).constructor;for(;r&&r!==i;){const s=r[w2]||Ow(r);if(s&&s!==e)return s;r=Object.getPrototypeOf(r)}return s=>new s})}function Ow(t){return _o(t)?()=>{const n=Ow(fn(t));return n&&n()}:xo(t)}function gL(t){const n=t[hn],e=n.type;return 2===e?n.declTNode:1===e?t[Xr]:null}function k3(t){return function F2e(t,n){if("class"===n)return t.classes;if("style"===n)return t.styles;const e=t.attrs;if(e){const i=e.length;let r=0;for(;r<i;){const s=e[r];if(W7(s))break;if(0===s)r+=2;else if("number"==typeof s)for(r++;r<i&&"string"==typeof e[r];)r++;else{if(s===n)return e[r+1];r+=2}}}return null}(zs(),t)}const d6="__parameters__";function h6(t,n,e){return b2(()=>{const i=function Hw(t){return function(...e){if(t){const i=t(...e);for(const r in i)this[r]=i[r]}}}(n);function r(...s){if(this instanceof r)return i.apply(this,s),this;const a=new r(...s);return o.annotation=a,o;function o(c,l,u){const d=c.hasOwnProperty(d6)?c[d6]:Object.defineProperty(c,d6,{value:[]})[d6];for(;d.length<=u;)d.push(null);return(d[u]=d[u]||[]).push(a),c}}return e&&(r.prototype=Object.create(e.prototype)),r.prototype.ngMetadataName=t,r.annotationCls=r,r})}function m6(t,n){t.forEach(e=>Array.isArray(e)?m6(e,n):n(e))}function yL(t,n,e){n>=t.length?t.push(e):t.splice(n,0,e)}function Am(t,n){return n>=t.length-1?t.pop():t.splice(n,1)[0]}function yf(t,n){const e=[];for(let i=0;i<t;i++)e.push(n);return e}function m1(t,n,e){let i=g6(t,n);return i>=0?t[1|i]=e:(i=~i,function Q2e(t,n,e,i){let r=t.length;if(r==n)t.push(e,i);else if(1===r)t.push(i,t[0]),t[0]=e;else{for(r--,t.push(t[r-1],t[r]);r>n;)t[r]=t[r-2],r--;t[n]=e,t[n+1]=i}}(t,i,n,e)),i}function Vw(t,n){const e=g6(t,n);if(e>=0)return t[1|e]}function g6(t,n){return function _L(t,n,e){let i=0,r=t.length>>e;for(;r!==i;){const s=i+(r-i>>1),a=t[s<<e];if(n===a)return s<<e;a>n?r=s:i=s+1}return~(r<<e)}(t,n,1)}const _f=$0(h6("Optional"),8),bf=$0(h6("SkipSelf"),4);function Pm(t){return 128==(128&t.flags)}var S3=function(t){return t[t.Important=1]="Important",t[t.DashCase=2]="DashCase",t}(S3||{});const _ce=/^>|^->|<!--|-->|--!>|<!-$/g,bce=/(<|>)/g,wce="\u200b$1\u200b";const jw=new Map;let Cce=0;const qw="__ngContext__";function La(t,n){Ya(n)?(t[qw]=n[J2],function Tce(t){jw.set(t[J2],t)}(n)):t[qw]=n}let Gw;function Zw(t,n){return Gw(t,n)}function xf(t){const n=t[fr];return Aa(n)?n[fr]:n}function VL(t){return BL(t[el])}function FL(t){return BL(t[Ts])}function BL(t){for(;null!==t&&!Aa(t);)t=t[Ts];return t}function _6(t,n,e,i,r){if(null!=i){let s,a=!1;Aa(i)?s=i:Ya(i)&&(a=!0,i=i[Kr]);const o=rr(i);0===t&&null!==e?null==r?WL(n,e,o):a4(n,e,o,r||null,!0):1===t&&null!==e?a4(n,e,o,r||null,!0):2===t?function Um(t,n,e){const i=Fm(t,n);i&&function $ce(t,n,e,i){t.removeChild(n,e,i)}(t,i,n,e)}(n,o,a):3===t&&n.destroyNode(o),null!=s&&function qce(t,n,e,i,r){const s=e[T2];s!==rr(e)&&_6(n,t,i,s,r);for(let o=Zs;o<e.length;o++){const c=e[o];Mf(c[hn],c,t,n,i,s)}}(n,t,s,e,r)}}function Yw(t,n){return t.createComment(function DL(t){return t.replace(_ce,n=>n.replace(bce,wce))}(n))}function Hm(t,n,e){return t.createElement(n,e)}function $L(t,n){const e=t[nl],i=e.indexOf(n);a6(n),e.splice(i,1)}function Vm(t,n){if(t.length<=Zs)return;const e=Zs+n,i=t[e];if(i){const r=i[u1];null!==r&&r!==t&&$L(r,i),n>0&&(t[e-1][Ts]=i[Ts]);const s=Am(t,Zs+n);!function Pce(t,n){Mf(t,n,n[ii],2,null,null),n[Kr]=null,n[Xr]=null}(i[hn],i);const a=s[F1];null!==a&&a.detachView(s[hn]),i[fr]=null,i[Ts]=null,i[ui]&=-129}return i}function Kw(t,n){if(!(256&n[ui])){const e=n[ii];n[Y0]&&X0(n[Y0]),n[Xu]&&X0(n[Xu]),e.destroyNode&&Mf(t,n,e,3,null,null),function Hce(t){let n=t[el];if(!n)return Xw(t[hn],t);for(;n;){let e=null;if(Ya(n))e=n[el];else{const i=n[Zs];i&&(e=i)}if(!e){for(;n&&!n[Ts]&&n!==t;)Ya(n)&&Xw(n[hn],n),n=n[fr];null===n&&(n=t),Ya(n)&&Xw(n[hn],n),e=n&&n[Ts]}n=e}}(n)}}function Xw(t,n){if(!(256&n[ui])){n[ui]&=-129,n[ui]|=256,function Uce(t,n){let e;if(null!=t&&null!=(e=t.destroyHooks))for(let i=0;i<e.length;i+=2){const r=n[e[i]];if(!(r instanceof Wi)){const s=e[i+1];if(Array.isArray(s))for(let a=0;a<s.length;a+=2){const o=r[s[a]],c=s[a+1];ko(4,o,c);try{c.call(o)}finally{ko(5,o,c)}}else{ko(4,r,s);try{s.call(r)}finally{ko(5,r,s)}}}}}(t,n),function Bce(t,n){const e=t.cleanup,i=n[da];if(null!==e)for(let s=0;s<e.length-1;s+=2)if("string"==typeof e[s]){const a=e[s+3];a>=0?i[a]():i[-a].unsubscribe(),s+=2}else e[s].call(i[e[s+1]]);null!==i&&(n[da]=null);const r=n[x2];if(null!==r){n[x2]=null;for(let s=0;s<r.length;s++)(0,r[s])()}}(t,n),1===n[hn].type&&n[ii].destroy();const e=n[u1];if(null!==e&&Aa(n[fr])){e!==n[fr]&&$L(e,n);const i=n[F1];null!==i&&i.detachView(t)}!function Mce(t){jw.delete(t[J2])}(n)}}function Qw(t,n,e){return function jL(t,n,e){let i=n;for(;null!==i&&40&i.type;)i=(n=i).parent;if(null===i)return e[Kr];{const{componentOffset:r}=i;if(r>-1){const{encapsulation:s}=t.data[i.directiveStart+r];if(s===Co.None||s===Co.Emulated)return null}return ha(i,e)}}(t,n.parent,e)}function a4(t,n,e,i,r){t.insertBefore(n,e,i,r)}function WL(t,n,e){t.appendChild(n,e)}function qL(t,n,e,i,r){null!==i?a4(t,n,e,i,r):WL(t,n,e)}function Fm(t,n){return t.parentNode(n)}function GL(t,n,e){return YL(t,n,e)}let Jw,$m,iC,jm,YL=function ZL(t,n,e){return 40&t.type?ha(t,e):null};function Bm(t,n,e,i){const r=Qw(t,i,n),s=n[ii],o=GL(i.parent||n[Xr],i,n);if(null!=r)if(Array.isArray(e))for(let c=0;c<e.length;c++)qL(s,r,e[c],o,!1);else qL(s,r,e,o,!1);void 0!==Jw&&Jw(s,i,n,e,r)}function Tf(t,n){if(null!==n){const e=n.type;if(3&e)return ha(n,t);if(4&e)return eC(-1,t[n.index]);if(8&e){const i=n.child;if(null!==i)return Tf(t,i);{const r=t[n.index];return Aa(r)?eC(-1,r):rr(r)}}if(32&e)return Zw(n,t)()||rr(t[n.index]);{const i=XL(t,n);return null!==i?Array.isArray(i)?i[0]:Tf(xf(t[Lr]),i):Tf(t,n.next)}}return null}function XL(t,n){return null!==n?t[Lr][Xr].projection[n.projection]:null}function eC(t,n){const e=Zs+t+1;if(e<n.length){const i=n[e],r=i[hn].firstChild;if(null!==r)return Tf(i,r)}return n[T2]}function tC(t,n,e,i,r,s,a){for(;null!=e;){const o=i[e.index],c=e.type;if(a&&0===n&&(o&&La(rr(o),i),e.flags|=2),32!=(32&e.flags))if(8&c)tC(t,n,e.child,i,r,s,!1),_6(n,t,r,o,s);else if(32&c){const l=Zw(e,i);let u;for(;u=l();)_6(n,t,r,u,s);_6(n,t,r,o,s)}else 16&c?JL(t,n,i,e,r,s):_6(n,t,r,o,s);e=a?e.projectionNext:e.next}}function Mf(t,n,e,i,r,s){tC(e,i,t.firstChild,n,r,s,!1)}function JL(t,n,e,i,r,s){const a=e[Lr],c=a[Xr].projection[i.projection];if(Array.isArray(c))for(let l=0;l<c.length;l++)_6(n,t,r,c[l],s);else{let l=c;const u=a[fr];Pm(i)&&(l.flags|=128),tC(t,n,l,u,r,s,!0)}}function eP(t,n,e){""===e?t.removeAttribute(n,"class"):t.setAttribute(n,"class",e)}function tP(t,n,e){const{mergedAttrs:i,classes:r,styles:s}=e;null!==i&&Z5(t,n,i),null!==r&&eP(t,n,r),null!==s&&function Zce(t,n,e){t.setAttribute(n,"style",e)}(t,n,s)}function b6(t){return function nC(){if(void 0===$m&&($m=null,Mr.trustedTypes))try{$m=Mr.trustedTypes.createPolicy("angular",{createHTML:t=>t,createScript:t=>t,createScriptURL:t=>t})}catch{}return $m}()?.createHTML(t)||t}function w6(){if(void 0!==iC)return iC;if(typeof document<"u")return document;throw new kt(210,!1)}function rC(){if(void 0===jm&&(jm=null,Mr.trustedTypes))try{jm=Mr.trustedTypes.createPolicy("angular#unsafe-bypass",{createHTML:t=>t,createScript:t=>t,createScriptURL:t=>t})}catch{}return jm}function nP(t){return rC()?.createHTML(t)||t}function rP(t){return rC()?.createScriptURL(t)||t}class o4{constructor(n){this.changingThisBreaksApplicationSecurity=n}toString(){return`SafeValue must use [property]=binding: ${this.changingThisBreaksApplicationSecurity} (see ${s1})`}}class Jce extends o4{getTypeName(){return"HTML"}}class ele extends o4{getTypeName(){return"Style"}}class tle extends o4{getTypeName(){return"Script"}}class nle extends o4{getTypeName(){return"URL"}}class ile extends o4{getTypeName(){return"ResourceURL"}}function g1(t){return t instanceof o4?t.changingThisBreaksApplicationSecurity:t}function dc(t,n){const e=function rle(t){return t instanceof o4&&t.getTypeName()||null}(t);if(null!=e&&e!==n){if("ResourceURL"===e&&"URL"===n)return!0;throw new Error(`Required a safe ${n}, got a ${e} (see ${s1})`)}return e===n}class ule{constructor(n){this.inertDocumentHelper=n}getInertBodyElement(n){n="<body><remove></remove>"+n;try{const e=(new window.DOMParser).parseFromString(b6(n),"text/html").body;return null===e?this.inertDocumentHelper.getInertBodyElement(n):(e.removeChild(e.firstChild),e)}catch{return null}}}class dle{constructor(n){this.defaultDoc=n,this.inertDocument=this.defaultDoc.implementation.createHTMLDocument("sanitization-inert")}getInertBodyElement(n){const e=this.inertDocument.createElement("template");return e.innerHTML=b6(n),e}}const hle=/^(?!javascript:)(?:[a-z0-9+.-]+:|[^&:\/?#]*(?:[\/?#]|$))/i;function Wm(t){return(t=String(t)).match(hle)?t:"unsafe:"+t}function dl(t){const n={};for(const e of t.split(","))n[e]=!0;return n}function kf(...t){const n={};for(const e of t)for(const i in e)e.hasOwnProperty(i)&&(n[i]=!0);return n}const aP=dl("area,br,col,hr,img,wbr"),oP=dl("colgroup,dd,dt,li,p,tbody,td,tfoot,th,thead,tr"),cP=dl("rp,rt"),sC=kf(aP,kf(oP,dl("address,article,aside,blockquote,caption,center,del,details,dialog,dir,div,dl,figure,figcaption,footer,h1,h2,h3,h4,h5,h6,header,hgroup,hr,ins,main,map,menu,nav,ol,pre,section,summary,table,ul")),kf(cP,dl("a,abbr,acronym,audio,b,bdi,bdo,big,br,cite,code,del,dfn,em,font,i,img,ins,kbd,label,map,mark,picture,q,ruby,rp,rt,s,samp,small,source,span,strike,strong,sub,sup,time,track,tt,u,var,video")),kf(cP,oP)),aC=dl("background,cite,href,itemtype,longdesc,poster,src,xlink:href"),lP=kf(aC,dl("abbr,accesskey,align,alt,autoplay,axis,bgcolor,border,cellpadding,cellspacing,class,clear,color,cols,colspan,compact,controls,coords,datetime,default,dir,download,face,headers,height,hidden,hreflang,hspace,ismap,itemscope,itemprop,kind,label,lang,language,loop,media,muted,nohref,nowrap,open,preload,rel,rev,role,rows,rowspan,rules,scope,scrolling,shape,size,sizes,span,srclang,srcset,start,summary,tabindex,target,title,translate,type,usemap,valign,value,vspace,width"),dl("aria-activedescendant,aria-atomic,aria-autocomplete,aria-busy,aria-checked,aria-colcount,aria-colindex,aria-colspan,aria-controls,aria-current,aria-describedby,aria-details,aria-disabled,aria-dropeffect,aria-errormessage,aria-expanded,aria-flowto,aria-grabbed,aria-haspopup,aria-hidden,aria-invalid,aria-keyshortcuts,aria-label,aria-labelledby,aria-level,aria-live,aria-modal,aria-multiline,aria-multiselectable,aria-orientation,aria-owns,aria-placeholder,aria-posinset,aria-pressed,aria-readonly,aria-relevant,aria-required,aria-roledescription,aria-rowcount,aria-rowindex,aria-rowspan,aria-selected,aria-setsize,aria-sort,aria-valuemax,aria-valuemin,aria-valuenow,aria-valuetext")),ple=dl("script,style,template");class mle{constructor(){this.sanitizedSomething=!1,this.buf=[]}sanitizeChildren(n){let e=n.firstChild,i=!0;for(;e;)if(e.nodeType===Node.ELEMENT_NODE?i=this.startElement(e):e.nodeType===Node.TEXT_NODE?this.chars(e.nodeValue):this.sanitizedSomething=!0,i&&e.firstChild)e=e.firstChild;else for(;e;){e.nodeType===Node.ELEMENT_NODE&&this.endElement(e);let r=this.checkClobberedElement(e,e.nextSibling);if(r){e=r;break}e=this.checkClobberedElement(e,e.parentNode)}return this.buf.join("")}startElement(n){const e=n.nodeName.toLowerCase();if(!sC.hasOwnProperty(e))return this.sanitizedSomething=!0,!ple.hasOwnProperty(e);this.buf.push("<"),this.buf.push(e);const i=n.attributes;for(let r=0;r<i.length;r++){const s=i.item(r),a=s.name,o=a.toLowerCase();if(!lP.hasOwnProperty(o)){this.sanitizedSomething=!0;continue}let c=s.value;aC[o]&&(c=Wm(c)),this.buf.push(" ",a,'="',uP(c),'"')}return this.buf.push(">"),!0}endElement(n){const e=n.nodeName.toLowerCase();sC.hasOwnProperty(e)&&!aP.hasOwnProperty(e)&&(this.buf.push("</"),this.buf.push(e),this.buf.push(">"))}chars(n){this.buf.push(uP(n))}checkClobberedElement(n,e){if(e&&(n.compareDocumentPosition(e)&Node.DOCUMENT_POSITION_CONTAINED_BY)===Node.DOCUMENT_POSITION_CONTAINED_BY)throw new Error(`Failed to sanitize html because the element is clobbered: ${n.outerHTML}`);return e}}const gle=/[\uD800-\uDBFF][\uDC00-\uDFFF]/g,vle=/([^\#-~ |!])/g;function uP(t){return t.replace(/&/g,"&amp;").replace(gle,function(n){return"&#"+(1024*(n.charCodeAt(0)-55296)+(n.charCodeAt(1)-56320)+65536)+";"}).replace(vle,function(n){return"&#"+n.charCodeAt(0)+";"}).replace(/</g,"&lt;").replace(/>/g,"&gt;")}let qm;function dP(t,n){let e=null;try{qm=qm||function sP(t){const n=new dle(t);return function fle(){try{return!!(new window.DOMParser).parseFromString(b6(""),"text/html")}catch{return!1}}()?new ule(n):n}(t);let i=n?String(n):"";e=qm.getInertBodyElement(i);let r=5,s=i;do{if(0===r)throw new Error("Failed to sanitize html because the input is unstable");r--,i=s,s=e.innerHTML,e=qm.getInertBodyElement(i)}while(i!==s);return b6((new mle).sanitizeChildren(oC(e)||e))}finally{if(e){const i=oC(e)||e;for(;i.firstChild;)i.removeChild(i.firstChild)}}}function oC(t){return"content"in t&&function yle(t){return t.nodeType===Node.ELEMENT_NODE&&"TEMPLATE"===t.nodeName}(t)?t.content:null}var v1=function(t){return t[t.NONE=0]="NONE",t[t.HTML=1]="HTML",t[t.STYLE=2]="STYLE",t[t.SCRIPT=3]="SCRIPT",t[t.URL=4]="URL",t[t.RESOURCE_URL=5]="RESOURCE_URL",t}(v1||{});function Gm(t){const n=Sf();return n?nP(n.sanitize(v1.HTML,t)||""):dc(t,"HTML")?nP(g1(t)):dP(w6(),Bn(t))}function Fi(t){const n=Sf();return n?n.sanitize(v1.URL,t)||"":dc(t,"URL")?g1(t):Wm(Bn(t))}function fP(t){const n=Sf();if(n)return rP(n.sanitize(v1.RESOURCE_URL,t)||"");if(dc(t,"ResourceURL"))return rP(g1(t));throw new kt(904,!1)}function Sf(){const t=Ot();return t&&t[fa].sanitizer}const Ef=new Jt("ENVIRONMENT_INITIALIZER"),pP=new Jt("INJECTOR",-1),mP=new Jt("INJECTOR_DEF_TYPES");class cC{get(n,e=F0){if(e===F0){const i=new Error(`NullInjectorError: No provider for ${ni(n)}!`);throw i.name="NullInjectorError",i}return e}}function Tle(...t){return{\u0275providers:gP(0,t),\u0275fromNgModule:!0}}function gP(t,...n){const e=[],i=new Set;let r;const s=a=>{e.push(a)};return m6(n,a=>{const o=a;Zm(o,s,[],i)&&(r||=[],r.push(o))}),void 0!==r&&vP(r,s),e}function vP(t,n){for(let e=0;e<t.length;e++){const{ngModule:i,providers:r}=t[e];uC(r,s=>{n(s,i)})}}function Zm(t,n,e,i){if(!(t=fn(t)))return!1;let r=null,s=ju(t);const a=!s&&Si(t);if(s||a){if(a&&!a.standalone)return!1;r=t}else{const c=t.ngModule;if(s=ju(c),!s)return!1;r=c}const o=i.has(r);if(a){if(o)return!1;if(i.add(r),a.dependencies){const c="function"==typeof a.dependencies?a.dependencies():a.dependencies;for(const l of c)Zm(l,n,e,i)}}else{if(!s)return!1;{if(null!=s.imports&&!o){let l;i.add(r);try{m6(s.imports,u=>{Zm(u,n,e,i)&&(l||=[],l.push(u))})}finally{}void 0!==l&&vP(l,n)}if(!o){const l=xo(r)||(()=>new r);n({provide:r,useFactory:l,deps:$i},r),n({provide:mP,useValue:r,multi:!0},r),n({provide:Ef,useValue:()=>gt(r),multi:!0},r)}const c=s.providers;if(null!=c&&!o){const l=t;uC(c,u=>{n(u,l)})}}}return r!==t&&void 0!==t.providers}function uC(t,n){for(let e of t)bo(e)&&(e=e.\u0275providers),Array.isArray(e)?uC(e,n):n(e)}const Mle=An({provide:String,useValue:An});function dC(t){return null!==t&&"object"==typeof t&&Mle in t}function c4(t){return"function"==typeof t}const fC=new Jt("Set Injector scope."),Ym={},Sle={};let hC;function Km(){return void 0===hC&&(hC=new cC),hC}class Ao{}class C6 extends Ao{get destroyed(){return this._destroyed}constructor(n,e,i,r){super(),this.parent=e,this.source=i,this.scopes=r,this.records=new Map,this._ngOnDestroyHooks=new Set,this._onDestroyHooks=[],this._destroyed=!1,mC(n,a=>this.processProvider(a)),this.records.set(pP,x6(void 0,this)),r.has("environment")&&this.records.set(Ao,x6(void 0,this));const s=this.records.get(fC);null!=s&&"string"==typeof s.value&&this.scopes.add(s.value),this.injectorDefTypes=new Set(this.get(mP.multi,$i,Mi.Self))}destroy(){this.assertNotDestroyed(),this._destroyed=!0;try{for(const e of this._ngOnDestroyHooks)e.ngOnDestroy();const n=this._onDestroyHooks;this._onDestroyHooks=[];for(const e of n)e()}finally{this.records.clear(),this._ngOnDestroyHooks.clear(),this.injectorDefTypes.clear()}}onDestroy(n){return this.assertNotDestroyed(),this._onDestroyHooks.push(n),()=>this.removeOnDestroy(n)}runInContext(n){this.assertNotDestroyed();const e=Q2(this),i=Ma(void 0);try{return n()}finally{Q2(e),Ma(i)}}get(n,e=F0,i=Mi.Default){if(this.assertNotDestroyed(),n.hasOwnProperty($7))return n[$7](this);i=U0(i);const s=Q2(this),a=Ma(void 0);try{if(!(i&Mi.SkipSelf)){let c=this.records.get(n);if(void 0===c){const l=function Nle(t){return"function"==typeof t||"object"==typeof t&&t instanceof Jt}(n)&&$u(n);c=l&&this.injectableDefInScope(l)?x6(pC(n),Ym):null,this.records.set(n,c)}if(null!=c)return this.hydrate(n,c)}return(i&Mi.Self?Km():this.parent).get(n,e=i&Mi.Optional&&e===F0?null:e)}catch(o){if("NullInjectorError"===o.name){if((o[Yc]=o[Yc]||[]).unshift(ni(n)),s)throw o;return function Xc(t,n,e,i){const r=t[Yc];throw n[B7]&&r.unshift(n[B7]),t.message=function fw(t,n,e,i=null){t=t&&"\n"===t.charAt(0)&&"\u0275"==t.charAt(1)?t.slice(2):t;let r=ni(n);if(Array.isArray(n))r=n.map(ni).join(" -> ");else if("object"==typeof n){let s=[];for(let a in n)if(n.hasOwnProperty(a)){let o=n[a];s.push(a+":"+("string"==typeof o?JSON.stringify(o):ni(o)))}r=`{${s.join(", ")}}`}return`${e}${i?"("+i+")":""}[${r}]: ${t.replace($5,"\n  ")}`}("\n"+t.message,r,e,i),t.ngTokenPath=r,t[Yc]=null,t}(o,n,"R3InjectorError",this.source)}throw o}finally{Ma(a),Q2(s)}}resolveInjectorInitializers(){const n=Q2(this),e=Ma(void 0);try{const r=this.get(Ef.multi,$i,Mi.Self);for(const s of r)s()}finally{Q2(n),Ma(e)}}toString(){const n=[],e=this.records;for(const i of e.keys())n.push(ni(i));return`R3Injector[${n.join(", ")}]`}assertNotDestroyed(){if(this._destroyed)throw new kt(205,!1)}processProvider(n){let e=c4(n=fn(n))?n:fn(n&&n.provide);const i=function Ale(t){return dC(t)?x6(void 0,t.useValue):x6(bP(t),Ym)}(n);if(c4(n)||!0!==n.multi)this.records.get(e);else{let r=this.records.get(e);r||(r=x6(void 0,Ym,!0),r.factory=()=>W5(r.multi),this.records.set(e,r)),e=n,r.multi.push(n)}this.records.set(e,i)}hydrate(n,e){return e.value===Ym&&(e.value=Sle,e.value=e.factory()),"object"==typeof e.value&&e.value&&function Dle(t){return null!==t&&"object"==typeof t&&"function"==typeof t.ngOnDestroy}(e.value)&&this._ngOnDestroyHooks.add(e.value),e.value}injectableDefInScope(n){if(!n.providedIn)return!1;const e=fn(n.providedIn);return"string"==typeof e?"any"===e||this.scopes.has(e):this.injectorDefTypes.has(e)}removeOnDestroy(n){const e=this._onDestroyHooks.indexOf(n);-1!==e&&this._onDestroyHooks.splice(e,1)}}function pC(t){const n=$u(t),e=null!==n?n.factory:xo(t);if(null!==e)return e;if(t instanceof Jt)throw new kt(204,!1);if(t instanceof Function)return function Ele(t){const n=t.length;if(n>0)throw yf(n,"?"),new kt(204,!1);const e=function cw(t){return t&&(t[Wu]||t[O7])||null}(t);return null!==e?()=>e.factory(t):()=>new t}(t);throw new kt(204,!1)}function bP(t,n,e){let i;if(c4(t)){const r=fn(t);return xo(r)||pC(r)}if(dC(t))i=()=>fn(t.useValue);else if(function _P(t){return!(!t||!t.useFactory)}(t))i=()=>t.useFactory(...W5(t.deps||[]));else if(function yP(t){return!(!t||!t.useExisting)}(t))i=()=>gt(fn(t.useExisting));else{const r=fn(t&&(t.useClass||t.provide));if(!function Ile(t){return!!t.deps}(t))return xo(r)||pC(r);i=()=>new r(...W5(t.deps))}return i}function x6(t,n,e=!1){return{factory:t,value:n,multi:e?[]:void 0}}function mC(t,n){for(const e of t)Array.isArray(e)?mC(e,n):e&&bo(e)?mC(e.\u0275providers,n):n(e)}const Af=new Jt("AppId",{providedIn:"root",factory:()=>Rle}),Rle="ng",wP=new Jt("Platform Initializer"),l4=new Jt("Platform ID",{providedIn:"platform",factory:()=>"unknown"}),CP=new Jt("AnimationModuleType"),gC=new Jt("CSP nonce",{providedIn:"root",factory:()=>w6().body?.querySelector("[ngCspNonce]")?.getAttribute("ngCspNonce")||null});let xP=(t,n,e)=>null;function TC(t,n,e=!1){return xP(t,n,e)}class $le{}class kP{}class Wle{resolveComponentFactory(n){throw function jle(t){const n=Error(`No component factory found for ${ni(t)}.`);return n.ngComponent=t,n}(n)}}let Nf=(()=>{class t{static#e=this.NULL=new Wle}return t})();function qle(){return k6(zs(),Ot())}function k6(t,n){return new $n(ha(t,n))}let $n=(()=>{class t{constructor(e){this.nativeElement=e}static#e=this.__NG_ELEMENT_ID__=qle}return t})();function Gle(t){return t instanceof $n?t.nativeElement:t}class S6{}let Io=(()=>{class t{constructor(){this.destroyNode=null}static#e=this.__NG_ELEMENT_ID__=()=>function Zle(){const t=Ot(),e=Ks(zs().index,t);return(Ya(e)?e:t)[ii]}()}return t})(),Yle=(()=>{class t{static#e=this.\u0275prov=Pt({token:t,providedIn:"root",factory:()=>null})}return t})();class u4{constructor(n){this.full=n,this.major=n.split(".")[0],this.minor=n.split(".")[1],this.patch=n.split(".").slice(2).join(".")}}const Kle=new u4("16.2.12"),SC={};function DP(t,n=null,e=null,i){const r=NP(t,n,e,i);return r.resolveInjectorInitializers(),r}function NP(t,n=null,e=null,i,r=new Set){const s=[e||$i,Tle(t)];return i=i||("object"==typeof t?void 0:ni(t)),new C6(s,n||Km(),i||null,r)}let ks=(()=>{class t{static#e=this.THROW_IF_NOT_FOUND=F0;static#t=this.NULL=new cC;static create(e,i){if(Array.isArray(e))return DP({name:""},i,e,"");{const r=e.name??"";return DP({name:r},e.parent,e.providers,r)}}static#n=this.\u0275prov=Pt({token:t,providedIn:"any",factory:()=>gt(pP)});static#i=this.__NG_ELEMENT_ID__=-1}return t})();function EC(t){return t.ngOriginalError}class fl{constructor(){this._console=console}handleError(n){const e=this._findOriginalError(n);this._console.error("ERROR",n),e&&this._console.error("ORIGINAL ERROR",e)}_findOriginalError(n){let e=n&&EC(n);for(;e&&EC(e);)e=EC(e);return e||null}}function AC(t){return n=>{setTimeout(t,void 0,n)}}const Ht=class r3e extends U{constructor(n=!1){super(),this.__isAsync=n}emit(n){super.next(n)}subscribe(n,e,i){let r=n,s=e||(()=>null),a=i;if(n&&"object"==typeof n){const c=n;r=c.next?.bind(c),s=c.error?.bind(c),a=c.complete?.bind(c)}this.__isAsync&&(s=AC(s),r&&(r=AC(r)),a&&(a=AC(a)));const o=super.subscribe({next:r,error:s,complete:a});return n instanceof w&&n.add(o),o}};function LP(...t){}class Xn{constructor({enableLongStackTrace:n=!1,shouldCoalesceEventChangeDetection:e=!1,shouldCoalesceRunChangeDetection:i=!1}){if(this.hasPendingMacrotasks=!1,this.hasPendingMicrotasks=!1,this.isStable=!0,this.onUnstable=new Ht(!1),this.onMicrotaskEmpty=new Ht(!1),this.onStable=new Ht(!1),this.onError=new Ht(!1),typeof Zone>"u")throw new kt(908,!1);Zone.assertZonePatched();const r=this;r._nesting=0,r._outer=r._inner=Zone.current,Zone.TaskTrackingZoneSpec&&(r._inner=r._inner.fork(new Zone.TaskTrackingZoneSpec)),n&&Zone.longStackTraceZoneSpec&&(r._inner=r._inner.fork(Zone.longStackTraceZoneSpec)),r.shouldCoalesceEventChangeDetection=!i&&e,r.shouldCoalesceRunChangeDetection=i,r.lastRequestAnimationFrameId=-1,r.nativeRequestAnimationFrame=function s3e(){const t="function"==typeof Mr.requestAnimationFrame;let n=Mr[t?"requestAnimationFrame":"setTimeout"],e=Mr[t?"cancelAnimationFrame":"clearTimeout"];if(typeof Zone<"u"&&n&&e){const i=n[Zone.__symbol__("OriginalDelegate")];i&&(n=i);const r=e[Zone.__symbol__("OriginalDelegate")];r&&(e=r)}return{nativeRequestAnimationFrame:n,nativeCancelAnimationFrame:e}}().nativeRequestAnimationFrame,function c3e(t){const n=()=>{!function o3e(t){t.isCheckStableRunning||-1!==t.lastRequestAnimationFrameId||(t.lastRequestAnimationFrameId=t.nativeRequestAnimationFrame.call(Mr,()=>{t.fakeTopEventTask||(t.fakeTopEventTask=Zone.root.scheduleEventTask("fakeTopEventTask",()=>{t.lastRequestAnimationFrameId=-1,DC(t),t.isCheckStableRunning=!0,IC(t),t.isCheckStableRunning=!1},void 0,()=>{},()=>{})),t.fakeTopEventTask.invoke()}),DC(t))}(t)};t._inner=t._inner.fork({name:"angular",properties:{isAngularZone:!0},onInvokeTask:(e,i,r,s,a,o)=>{if(function u3e(t){return!(!Array.isArray(t)||1!==t.length)&&!0===t[0].data?.__ignore_ng_zone__}(o))return e.invokeTask(r,s,a,o);try{return PP(t),e.invokeTask(r,s,a,o)}finally{(t.shouldCoalesceEventChangeDetection&&"eventTask"===s.type||t.shouldCoalesceRunChangeDetection)&&n(),zP(t)}},onInvoke:(e,i,r,s,a,o,c)=>{try{return PP(t),e.invoke(r,s,a,o,c)}finally{t.shouldCoalesceRunChangeDetection&&n(),zP(t)}},onHasTask:(e,i,r,s)=>{e.hasTask(r,s),i===r&&("microTask"==s.change?(t._hasPendingMicrotasks=s.microTask,DC(t),IC(t)):"macroTask"==s.change&&(t.hasPendingMacrotasks=s.macroTask))},onHandleError:(e,i,r,s)=>(e.handleError(r,s),t.runOutsideAngular(()=>t.onError.emit(s)),!1)})}(r)}static isInAngularZone(){return typeof Zone<"u"&&!0===Zone.current.get("isAngularZone")}static assertInAngularZone(){if(!Xn.isInAngularZone())throw new kt(909,!1)}static assertNotInAngularZone(){if(Xn.isInAngularZone())throw new kt(909,!1)}run(n,e,i){return this._inner.run(n,e,i)}runTask(n,e,i,r){const s=this._inner,a=s.scheduleEventTask("NgZoneEvent: "+r,n,a3e,LP,LP);try{return s.runTask(a,e,i)}finally{s.cancelTask(a)}}runGuarded(n,e,i){return this._inner.runGuarded(n,e,i)}runOutsideAngular(n){return this._outer.run(n)}}const a3e={};function IC(t){if(0==t._nesting&&!t.hasPendingMicrotasks&&!t.isStable)try{t._nesting++,t.onMicrotaskEmpty.emit(null)}finally{if(t._nesting--,!t.hasPendingMicrotasks)try{t.runOutsideAngular(()=>t.onStable.emit(null))}finally{t.isStable=!0}}}function DC(t){t.hasPendingMicrotasks=!!(t._hasPendingMicrotasks||(t.shouldCoalesceEventChangeDetection||t.shouldCoalesceRunChangeDetection)&&-1!==t.lastRequestAnimationFrameId)}function PP(t){t._nesting++,t.isStable&&(t.isStable=!1,t.onUnstable.emit(null))}function zP(t){t._nesting--,IC(t)}class l3e{constructor(){this.hasPendingMicrotasks=!1,this.hasPendingMacrotasks=!1,this.isStable=!0,this.onUnstable=new Ht,this.onMicrotaskEmpty=new Ht,this.onStable=new Ht,this.onError=new Ht}run(n,e,i){return n.apply(e,i)}runGuarded(n,e,i){return n.apply(e,i)}runOutsideAngular(n){return n()}runTask(n,e,i,r){return n.apply(e,i)}}const OP=new Jt("",{providedIn:"root",factory:HP});function HP(){const t=Kt(Xn);let n=!0;return n1(new te(r=>{n=t.isStable&&!t.hasPendingMacrotasks&&!t.hasPendingMicrotasks,t.runOutsideAngular(()=>{r.next(n),r.complete()})}),new te(r=>{let s;t.runOutsideAngular(()=>{s=t.onStable.subscribe(()=>{Xn.assertNotInAngularZone(),queueMicrotask(()=>{!n&&!t.hasPendingMacrotasks&&!t.hasPendingMicrotasks&&(n=!0,r.next(!0))})})});const a=t.onUnstable.subscribe(()=>{Xn.assertInAngularZone(),n&&(n=!1,t.runOutsideAngular(()=>{r.next(!1)}))});return()=>{s.unsubscribe(),a.unsubscribe()}}).pipe(H1()))}function VP(t){return t.ownerDocument.defaultView}function fc(t){return t.ownerDocument}function hl(t){return t instanceof Function?t():t}let NC=(()=>{class t{constructor(){this.renderDepth=0,this.handler=null}begin(){this.handler?.validateBegin(),this.renderDepth++}end(){this.renderDepth--,0===this.renderDepth&&this.handler?.execute()}ngOnDestroy(){this.handler?.destroy(),this.handler=null}static#e=this.\u0275prov=Pt({token:t,providedIn:"root",factory:()=>new t})}return t})();function Rf(t){for(;t;){t[ui]|=64;const n=xf(t);if(e6(t)&&!n)return t;t=n}return null}const jP=new Jt("",{providedIn:"root",factory:()=>!1});let r9=null;function ZP(t,n){return t[n]??XP()}function YP(t,n){const e=XP();e.producerNode?.length&&(t[n]=r9,e.lView=t,r9=KP())}const y3e={...ef,consumerIsAlwaysLive:!0,consumerMarkedDirty:t=>{Rf(t.lView)},lView:null};function KP(){return Object.create(y3e)}function XP(){return r9??=KP(),r9}const di={};function v(t){QP(Ri(),Ot(),ma()+t,!1)}function QP(t,n,e,i){if(!i)if(3==(3&n[ui])){const s=t.preOrderCheckHooks;null!==s&&fe(n,s,e)}else{const s=t.preOrderHooks;null!==s&&xe(n,s,0,e)}Ms(e)}function Te(t,n=Mi.Default){const e=Ot();return null===e?gt(t,n):fL(zs(),e,fn(t),n)}function s9(t,n,e,i,r,s,a,o,c,l,u){const d=n.blueprint.slice();return d[Kr]=r,d[ui]=140|i,(null!==l||t&&2048&t[ui])&&(d[ui]|=2048),gm(d),d[fr]=d[f3]=t,d[rs]=e,d[fa]=a||t&&t[fa],d[ii]=o||t&&t[ii],d[Ea]=c||t&&t[Ea]||null,d[Xr]=s,d[J2]=function xce(){return Cce++}(),d[Za]=u,d[X7]=l,d[Lr]=2==n.type?t[Lr]:d,d}function D6(t,n,e,i,r){let s=t.data[n];if(null===s)s=function RC(t,n,e,i,r){const s=l6(),a=t4(),c=t.data[n]=function k3e(t,n,e,i,r,s){let a=n?n.injectorIndex:-1,o=0;return w3()&&(o|=128),{type:e,index:i,insertBeforeIndex:null,injectorIndex:a,directiveStart:-1,directiveEnd:-1,directiveStylingLast:-1,componentOffset:-1,propertyBindings:null,flags:o,providerIndexes:0,value:r,attrs:s,mergedAttrs:null,localNames:null,initialInputs:void 0,inputs:null,outputs:null,tView:null,next:null,prev:null,projectionNext:null,child:null,parent:n,projection:null,styles:null,stylesWithoutHost:null,residualStyles:void 0,classes:null,classesWithoutHost:null,residualClasses:void 0,classBindings:0,styleBindings:0}}(0,a?s:s&&s.parent,e,n,i,r);return null===t.firstChild&&(t.firstChild=c),null!==s&&(a?null==s.child&&null!==c.parent&&(s.child=c):null===s.next&&(s.next=c,c.prev=s)),c}(t,n,e,i,r),function x3(){return Nn.lFrame.inI18n}()&&(s.flags|=32);else if(64&s.type){s.type=e,s.value=i,s.attrs=r;const a=function W1(){const t=Nn.lFrame,n=t.currentTNode;return t.isParent?n:n.parent}();s.injectorIndex=null===a?-1:a.injectorIndex}return q1(s,!0),s}function Lf(t,n,e,i){if(0===e)return-1;const r=n.length;for(let s=0;s<e;s++)n.push(i),t.blueprint.push(i),t.data.push(null);return r}function ez(t,n,e,i,r){const s=ZP(n,Y0),a=ma(),o=2&i;try{Ms(-1),o&&n.length>Ei&&QP(t,n,Ei,!1),ko(o?2:0,r);const l=o?s:null,u=Ys(l);try{null!==l&&(l.dirty=!1),e(i,r)}finally{nf(l,u)}}finally{o&&null===n[Y0]&&YP(n,Y0),Ms(a),ko(o?3:1,r)}}function LC(t,n,e){if(J7(n)){const i=Pr(null);try{const s=n.directiveEnd;for(let a=n.directiveStart;a<s;a++){const o=t.data[a];o.contentQueries&&o.contentQueries(1,e[a],a)}}finally{Pr(i)}}}function PC(t,n,e){j1()&&(function R3e(t,n,e,i){const r=e.directiveStart,s=e.directiveEnd;p3(e)&&function F3e(t,n,e){const i=ha(n,t),r=tz(e);let a=16;e.signals?a=4096:e.onPush&&(a=64);const o=a9(t,s9(t,r,null,a,i,n,null,t[fa].rendererFactory.createRenderer(i,e),null,null,null));t[n.index]=o}(n,e,t.data[r+e.componentOffset]),t.firstCreatePass||km(e,n),La(i,n);const a=e.initialInputs;for(let o=r;o<s;o++){const c=t.data[o],l=s4(n,t,o,e);La(l,n),null!==a&&B3e(0,o-r,l,c,0,a),Ia(c)&&(Ks(e.index,n)[rs]=s4(n,t,o,e))}}(t,n,e,ha(e,n)),64==(64&e.flags)&&az(t,n,e))}function zC(t,n,e=ha){const i=n.localNames;if(null!==i){let r=n.index+1;for(let s=0;s<i.length;s+=2){const a=i[s+1],o=-1===a?e(n,t):t[a];t[r++]=o}}}function tz(t){const n=t.tView;return null===n||n.incompleteFirstPass?t.tView=OC(1,null,t.template,t.decls,t.vars,t.directiveDefs,t.pipeDefs,t.viewQuery,t.schemas,t.consts,t.id):n}function OC(t,n,e,i,r,s,a,o,c,l,u){const d=Ei+i,h=d+r,y=function b3e(t,n){const e=[];for(let i=0;i<n;i++)e.push(i<t?null:di);return e}(d,h),I="function"==typeof l?l():l;return y[hn]={type:t,blueprint:y,template:e,queries:null,viewQuery:o,declTNode:n,data:y.slice().fill(null,d),bindingStartIndex:d,expandoStartIndex:h,hostBindingOpCodes:null,firstCreatePass:!0,firstUpdatePass:!0,staticViewQueries:!1,staticContentQueries:!1,preOrderHooks:null,preOrderCheckHooks:null,contentHooks:null,contentCheckHooks:null,viewHooks:null,viewCheckHooks:null,destroyHooks:null,cleanup:null,contentQueries:null,components:null,directiveRegistry:"function"==typeof s?s():s,pipeRegistry:"function"==typeof a?a():a,firstChild:null,schemas:c,consts:I,incompleteFirstPass:!1,ssrId:u}}let nz=t=>null;function iz(t,n,e,i){for(let r in t)if(t.hasOwnProperty(r)){e=null===e?{}:e;const s=t[r];null===i?rz(e,n,r,s):i.hasOwnProperty(r)&&rz(e,n,i[r],s)}return e}function rz(t,n,e,i){t.hasOwnProperty(e)?t[e].push(n,i):t[e]=[n,i]}function y1(t,n,e,i,r,s,a,o){const c=ha(n,e);let u,l=n.inputs;!o&&null!=l&&(u=l[i])?(UC(t,e,u,i,r),p3(n)&&function A3e(t,n){const e=Ks(n,t);16&e[ui]||(e[ui]|=64)}(e,n.index)):3&n.type&&(i=function E3e(t){return"class"===t?"className":"for"===t?"htmlFor":"formaction"===t?"formAction":"innerHtml"===t?"innerHTML":"readonly"===t?"readOnly":"tabindex"===t?"tabIndex":t}(i),r=null!=a?a(r,n.value||"",i):r,s.setProperty(c,i,r))}function HC(t,n,e,i){if(j1()){const r=null===i?null:{"":-1},s=function P3e(t,n){const e=t.directiveRegistry;let i=null,r=null;if(e)for(let s=0;s<e.length;s++){const a=e[s];if(ir(n,a.selectors,!1))if(i||(i=[]),Ia(a))if(null!==a.findHostDirectiveDefs){const o=[];r=r||new Map,a.findHostDirectiveDefs(a,o,r),i.unshift(...o,a),VC(t,n,o.length)}else i.unshift(a),VC(t,n,0);else r=r||new Map,a.findHostDirectiveDefs?.(a,i,r),i.push(a)}return null===i?null:[i,r]}(t,e);let a,o;null===s?a=o=null:[a,o]=s,null!==a&&sz(t,n,e,a,r,o),r&&function z3e(t,n,e){if(n){const i=t.localNames=[];for(let r=0;r<n.length;r+=2){const s=e[n[r+1]];if(null==s)throw new kt(-301,!1);i.push(n[r],s)}}}(e,i,r)}e.mergedAttrs=W0(e.mergedAttrs,e.attrs)}function sz(t,n,e,i,r,s){for(let l=0;l<i.length;l++)zw(km(e,n),t,i[l].type);!function H3e(t,n,e){t.flags|=1,t.directiveStart=n,t.directiveEnd=n+e,t.providerIndexes=n}(e,t.data.length,i.length);for(let l=0;l<i.length;l++){const u=i[l];u.providersResolver&&u.providersResolver(u)}let a=!1,o=!1,c=Lf(t,n,i.length,null);for(let l=0;l<i.length;l++){const u=i[l];e.mergedAttrs=W0(e.mergedAttrs,u.hostAttrs),V3e(t,e,n,c,u),O3e(c,u,r),null!==u.contentQueries&&(e.flags|=4),(null!==u.hostBindings||null!==u.hostAttrs||0!==u.hostVars)&&(e.flags|=64);const d=u.type.prototype;!a&&(d.ngOnChanges||d.ngOnInit||d.ngDoCheck)&&((t.preOrderHooks??=[]).push(e.index),a=!0),!o&&(d.ngOnChanges||d.ngDoCheck)&&((t.preOrderCheckHooks??=[]).push(e.index),o=!0),c++}!function S3e(t,n,e){const r=n.directiveEnd,s=t.data,a=n.attrs,o=[];let c=null,l=null;for(let u=n.directiveStart;u<r;u++){const d=s[u],h=e?e.get(d):null,I=h?h.outputs:null;c=iz(d.inputs,u,c,h?h.inputs:null),l=iz(d.outputs,u,l,I);const D=null===c||null===a||Y7(n)?null:U3e(c,u,a);o.push(D)}null!==c&&(c.hasOwnProperty("class")&&(n.flags|=8),c.hasOwnProperty("style")&&(n.flags|=16)),n.initialInputs=o,n.inputs=c,n.outputs=l}(t,e,s)}function az(t,n,e){const i=e.directiveStart,r=e.directiveEnd,s=e.index,a=function T3(){return Nn.lFrame.currentDirectiveIndex}();try{Ms(s);for(let o=i;o<r;o++){const c=t.data[o],l=n[o];df(o),(null!==c.hostBindings||0!==c.hostVars||null!==c.hostAttrs)&&L3e(c,l)}}finally{Ms(-1),df(a)}}function L3e(t,n){null!==t.hostBindings&&t.hostBindings(1,n)}function VC(t,n,e){n.componentOffset=e,(t.components??=[]).push(n.index)}function O3e(t,n,e){if(e){if(n.exportAs)for(let i=0;i<n.exportAs.length;i++)e[n.exportAs[i]]=t;Ia(n)&&(e[""]=t)}}function V3e(t,n,e,i,r){t.data[i]=r;const s=r.factory||(r.factory=xo(r.type)),a=new Wi(s,Ia(r),Te);t.blueprint[i]=a,e[i]=a,function D3e(t,n,e,i,r){const s=r.hostBindings;if(s){let a=t.hostBindingOpCodes;null===a&&(a=t.hostBindingOpCodes=[]);const o=~n.index;(function N3e(t){let n=t.length;for(;n>0;){const e=t[--n];if("number"==typeof e&&e<0)return e}return 0})(a)!=o&&a.push(o),a.push(e,i,s)}}(t,n,i,Lf(t,e,r.hostVars,di),r)}function hc(t,n,e,i,r,s){const a=ha(t,n);!function FC(t,n,e,i,r,s,a){if(null==s)t.removeAttribute(n,r,e);else{const o=null==a?Bn(s):a(s,i||"",r);t.setAttribute(n,r,o,e)}}(n[ii],a,s,t.value,e,i,r)}function B3e(t,n,e,i,r,s){const a=s[n];if(null!==a)for(let o=0;o<a.length;)oz(i,e,a[o++],a[o++],a[o++])}function oz(t,n,e,i,r){const s=Pr(null);try{const a=t.inputTransforms;null!==a&&a.hasOwnProperty(i)&&(r=a[i].call(n,r)),null!==t.setInput?t.setInput(n,r,e,i):n[i]=r}finally{Pr(s)}}function U3e(t,n,e){let i=null,r=0;for(;r<e.length;){const s=e[r];if(0!==s)if(5!==s){if("number"==typeof s)break;if(t.hasOwnProperty(s)){null===i&&(i=[]);const a=t[s];for(let o=0;o<a.length;o+=2)if(a[o]===n){i.push(s,a[o+1],e[r+1]);break}}r+=2}else r+=2;else r+=4}return i}function cz(t,n,e,i){return[t,!0,!1,n,null,0,i,e,null,null,null]}function lz(t,n){const e=t.contentQueries;if(null!==e)for(let i=0;i<e.length;i+=2){const s=e[i+1];if(-1!==s){const a=t.data[s];ff(e[i]),a.contentQueries(2,n[s],s)}}}function a9(t,n){return t[el]?t[tl][Ts]=n:t[el]=n,t[tl]=n,n}function BC(t,n,e){ff(0);const i=Pr(null);try{n(t,e)}finally{Pr(i)}}function uz(t){return t[da]||(t[da]=[])}function dz(t){return t.cleanup||(t.cleanup=[])}function fz(t,n,e){return(null===t||Ia(t))&&(e=function A2(t){for(;Array.isArray(t);){if("object"==typeof t[Q7])return t;t=t[Kr]}return null}(e[n.index])),e[ii]}function hz(t,n){const e=t[Ea],i=e?e.get(fl,null):null;i&&i.handleError(n)}function UC(t,n,e,i,r){for(let s=0;s<e.length;){const a=e[s++],o=e[s++];oz(t.data[a],n[a],i,o,r)}}function pl(t,n,e){const i=r6(n,t);!function UL(t,n,e){t.setValue(n,e)}(t[ii],i,e)}function $3e(t,n){const e=Ks(n,t),i=e[hn];!function j3e(t,n){for(let e=n.length;e<t.blueprint.length;e++)n.push(t.blueprint[e])}(i,e);const r=e[Kr];null!==r&&null===e[Za]&&(e[Za]=TC(r,e[Ea])),$C(i,e,e[rs])}function $C(t,n,e){hf(n);try{const i=t.viewQuery;null!==i&&BC(1,i,e);const r=t.template;null!==r&&ez(t,n,r,1,e),t.firstCreatePass&&(t.firstCreatePass=!1),t.staticContentQueries&&lz(t,n),t.staticViewQueries&&BC(2,t.viewQuery,e);const s=t.components;null!==s&&function W3e(t,n){for(let e=0;e<n.length;e++)$3e(t,n[e])}(n,s)}catch(i){throw t.firstCreatePass&&(t.incompleteFirstPass=!0,t.firstCreatePass=!1),i}finally{n[ui]&=-5,pf()}}let pz=(()=>{class t{constructor(){this.all=new Set,this.queue=new Map}create(e,i,r){const s=typeof Zone>"u"?null:Zone.current,a=function Mw(t,n,e){const i=Object.create(ol);e&&(i.consumerAllowSignalWrites=!0),i.fn=t,i.schedule=n;const r=a=>{i.cleanupFn=a};return i.ref={notify:()=>To(i),run:()=>{if(i.dirty=!1,i.hasRun&&!am(i))return;i.hasRun=!0;const a=Ys(i);try{i.cleanupFn(),i.cleanupFn=hm,i.fn(r)}finally{nf(i,a)}},cleanup:()=>i.cleanupFn()},i.ref}(e,l=>{this.all.has(l)&&this.queue.set(l,s)},r);let o;this.all.add(a),a.notify();const c=()=>{a.cleanup(),o?.(),this.all.delete(a),this.queue.delete(a)};return o=i?.onDestroy(c),{destroy:c}}flush(){if(0!==this.queue.size)for(const[e,i]of this.queue)this.queue.delete(e),i?i.run(()=>e.run()):e.run()}get isQueueEmpty(){return 0===this.queue.size}static#e=this.\u0275prov=Pt({token:t,providedIn:"root",factory:()=>new t})}return t})();function o9(t,n,e){let i=e?t.styles:null,r=e?t.classes:null,s=0;if(null!==n)for(let a=0;a<n.length;a++){const o=n[a];"number"==typeof o?s=o:1==s?r=nr(r,o):2==s&&(i=nr(i,o+": "+n[++a]+";"))}e?t.styles=i:t.stylesWithoutHost=i,e?t.classes=r:t.classesWithoutHost=r}function Pf(t,n,e,i,r=!1){for(;null!==e;){const s=n[e.index];null!==s&&i.push(rr(s)),Aa(s)&&mz(s,i);const a=e.type;if(8&a)Pf(t,n,e.child,i);else if(32&a){const o=Zw(e,n);let c;for(;c=o();)i.push(c)}else if(16&a){const o=XL(n,e);if(Array.isArray(o))i.push(...o);else{const c=xf(n[Lr]);Pf(c[hn],c,o,i,!0)}}e=r?e.projectionNext:e.next}return i}function mz(t,n){for(let e=Zs;e<t.length;e++){const i=t[e],r=i[hn].firstChild;null!==r&&Pf(i[hn],i,r,n)}t[T2]!==t[Kr]&&n.push(t[T2])}function c9(t,n,e,i=!0){const r=n[fa],s=r.rendererFactory,a=r.afterRenderEventManager;s.begin?.(),a?.begin();try{gz(t,n,t.template,e)}catch(c){throw i&&hz(n,c),c}finally{s.end?.(),r.effectManager?.flush(),a?.end()}}function gz(t,n,e,i){const r=n[ui];if(256!=(256&r)){n[fa].effectManager?.flush(),hf(n);try{gm(n),function Z1(t){return Nn.lFrame.bindingIndex=t}(t.bindingStartIndex),null!==e&&ez(t,n,e,2,i);const a=3==(3&r);if(a){const l=t.preOrderCheckHooks;null!==l&&fe(n,l,null)}else{const l=t.preOrderHooks;null!==l&&xe(n,l,0,null),G(n,0)}if(function Z3e(t){for(let n=VL(t);null!==n;n=FL(n)){if(!n[_w])continue;const e=n[nl];for(let i=0;i<e.length;i++){cf(e[i])}}}(n),vz(n,2),null!==t.contentQueries&&lz(t,n),a){const l=t.contentCheckHooks;null!==l&&fe(n,l)}else{const l=t.contentHooks;null!==l&&xe(n,l,1),G(n,1)}!function _3e(t,n){const e=t.hostBindingOpCodes;if(null===e)return;const i=ZP(n,Xu);try{for(let r=0;r<e.length;r++){const s=e[r];if(s<0)Ms(~s);else{const a=s,o=e[++r],c=e[++r];uf(o,a),i.dirty=!1;const l=Ys(i);try{c(2,n[a])}finally{nf(i,l)}}}}finally{null===n[Xu]&&YP(n,Xu),Ms(-1)}}(t,n);const o=t.components;null!==o&&_z(n,o,0);const c=t.viewQuery;if(null!==c&&BC(2,c,i),a){const l=t.viewCheckHooks;null!==l&&fe(n,l)}else{const l=t.viewHooks;null!==l&&xe(n,l,2),G(n,2)}!0===t.firstUpdatePass&&(t.firstUpdatePass=!1),n[ui]&=-73,a6(n)}finally{pf()}}}function vz(t,n){for(let e=VL(t);null!==e;e=FL(e))for(let i=Zs;i<e.length;i++)yz(e[i],n)}function Y3e(t,n,e){yz(Ks(n,t),e)}function yz(t,n){if(!function Aw(t){return 128==(128&t[ui])}(t))return;const e=t[hn],i=t[ui];if(80&i&&0===n||1024&i||2===n)gz(e,t,e.template,t[rs]);else if(t[Z0]>0){vz(t,1);const r=e.components;null!==r&&_z(t,r,1)}}function _z(t,n,e){for(let i=0;i<n.length;i++)Y3e(t,n[i],e)}class zf{get rootNodes(){const n=this._lView,e=n[hn];return Pf(e,n,e.firstChild,[])}constructor(n,e){this._lView=n,this._cdRefInjectingView=e,this._appRef=null,this._attachedToViewContainer=!1}get context(){return this._lView[rs]}set context(n){this._lView[rs]=n}get destroyed(){return 256==(256&this._lView[ui])}destroy(){if(this._appRef)this._appRef.detachView(this);else if(this._attachedToViewContainer){const n=this._lView[fr];if(Aa(n)){const e=n[8],i=e?e.indexOf(this):-1;i>-1&&(Vm(n,i),Am(e,i))}this._attachedToViewContainer=!1}Kw(this._lView[hn],this._lView)}onDestroy(n){!function vm(t,n){if(256==(256&t[ui]))throw new kt(911,!1);null===t[x2]&&(t[x2]=[]),t[x2].push(n)}(this._lView,n)}markForCheck(){Rf(this._cdRefInjectingView||this._lView)}detach(){this._lView[ui]&=-129}reattach(){this._lView[ui]|=128}detectChanges(){c9(this._lView[hn],this._lView,this.context)}checkNoChanges(){}attachToViewContainerRef(){if(this._appRef)throw new kt(902,!1);this._attachedToViewContainer=!0}detachFromAppRef(){this._appRef=null,function Oce(t,n){Mf(t,n,n[ii],2,null,null)}(this._lView[hn],this._lView)}attachToAppRef(n){if(this._attachedToViewContainer)throw new kt(902,!1);this._appRef=n}}class K3e extends zf{constructor(n){super(n),this._view=n}detectChanges(){const n=this._view;c9(n[hn],n,n[rs],!1)}checkNoChanges(){}get context(){return null}}class bz extends Nf{constructor(n){super(),this.ngModule=n}resolveComponentFactory(n){const e=Si(n);return new Of(e,this.ngModule)}}function wz(t){const n=[];for(let e in t)t.hasOwnProperty(e)&&n.push({propName:t[e],templateName:e});return n}class Q3e{constructor(n,e){this.injector=n,this.parentInjector=e}get(n,e,i){i=U0(i);const r=this.injector.get(n,SC,i);return r!==SC||e===SC?r:this.parentInjector.get(n,e,i)}}class Of extends kP{get inputs(){const n=this.componentDef,e=n.inputTransforms,i=wz(n.inputs);if(null!==e)for(const r of i)e.hasOwnProperty(r.propName)&&(r.transform=e[r.propName]);return i}get outputs(){return wz(this.componentDef.outputs)}constructor(n,e){super(),this.componentDef=n,this.ngModule=e,this.componentType=n.type,this.selector=function vw(t){return t.map(Qc).join(",")}(n.selectors),this.ngContentSelectors=n.ngContentSelectors?n.ngContentSelectors:[],this.isBoundToModule=!!e}create(n,e,i,r){let s=(r=r||this.ngModule)instanceof Ao?r:r?.injector;s&&null!==this.componentDef.getStandaloneInjector&&(s=this.componentDef.getStandaloneInjector(s)||s);const a=s?new Q3e(n,s):n,o=a.get(S6,null);if(null===o)throw new kt(407,!1);const d={rendererFactory:o,sanitizer:a.get(Yle,null),effectManager:a.get(pz,null),afterRenderEventManager:a.get(NC,null)},h=o.createRenderer(null,this.componentDef),y=this.componentDef.selectors[0][0]||"div",I=i?function w3e(t,n,e,i){const s=i.get(jP,!1)||e===Co.ShadowDom,a=t.selectRootElement(n,s);return function C3e(t){nz(t)}(a),a}(h,i,this.componentDef.encapsulation,a):Hm(h,y,function X3e(t){const n=t.toLowerCase();return"svg"===n?cl:"math"===n?"math":null}(y)),we=this.componentDef.signals?4608:this.componentDef.onPush?576:528;let Ce=null;null!==I&&(Ce=TC(I,a,!0));const Ve=OC(0,null,null,1,0,null,null,null,null,null,null),Fe=s9(null,Ve,null,we,null,null,d,h,a,null,Ce);let qe,nt;hf(Fe);try{const dt=this.componentDef;let mt,Et=null;dt.findHostDirectiveDefs?(mt=[],Et=new Map,dt.findHostDirectiveDefs(dt,mt,Et),mt.push(dt)):mt=[dt];const Bt=function e0e(t,n){const e=t[hn],i=Ei;return t[i]=n,D6(e,i,2,"#host",null)}(Fe,I),tn=function t0e(t,n,e,i,r,s,a){const o=r[hn];!function n0e(t,n,e,i){for(const r of t)n.mergedAttrs=W0(n.mergedAttrs,r.hostAttrs);null!==n.mergedAttrs&&(o9(n,n.mergedAttrs,!0),null!==e&&tP(i,e,n))}(i,t,n,a);let c=null;null!==n&&(c=TC(n,r[Ea]));const l=s.rendererFactory.createRenderer(n,e);let u=16;e.signals?u=4096:e.onPush&&(u=64);const d=s9(r,tz(e),null,u,r[t.index],t,s,l,null,null,c);return o.firstCreatePass&&VC(o,t,i.length-1),a9(r,d),r[t.index]=d}(Bt,I,dt,mt,Fe,d,h);nt=$1(Ve,Ei),I&&function r0e(t,n,e,i){if(i)Z5(t,e,["ng-version",Kle.full]);else{const{attrs:r,classes:s}=function C2(t){const n=[],e=[];let i=1,r=2;for(;i<t.length;){let s=t[i];if("string"==typeof s)2===r?""!==s&&n.push(s,t[++i]):8===r&&e.push(s);else{if(!qs(r))break;r=s}i++}return{attrs:n,classes:e}}(n.selectors[0]);r&&Z5(t,e,r),s&&s.length>0&&eP(t,e,s.join(" "))}}(h,dt,I,i),void 0!==e&&function s0e(t,n,e){const i=t.projection=[];for(let r=0;r<n.length;r++){const s=e[r];i.push(null!=s?Array.from(s):null)}}(nt,this.ngContentSelectors,e),qe=function i0e(t,n,e,i,r,s){const a=zs(),o=r[hn],c=ha(a,r);sz(o,r,a,e,null,i);for(let u=0;u<e.length;u++)La(s4(r,o,a.directiveStart+u,a),r);az(o,r,a),c&&La(c,r);const l=s4(r,o,a.directiveStart+a.componentOffset,a);if(t[rs]=r[rs]=l,null!==s)for(const u of s)u(l,n);return LC(o,a,t),l}(tn,dt,mt,Et,Fe,[a0e]),$C(Ve,Fe,null)}finally{pf()}return new J3e(this.componentType,qe,k6(nt,Fe),Fe,nt)}}class J3e extends $le{constructor(n,e,i,r,s){super(),this.location=i,this._rootLView=r,this._tNode=s,this.previousInputValues=null,this.instance=e,this.hostView=this.changeDetectorRef=new K3e(r),this.componentType=n}setInput(n,e){const i=this._tNode.inputs;let r;if(null!==i&&(r=i[n])){if(this.previousInputValues??=new Map,this.previousInputValues.has(n)&&Object.is(this.previousInputValues.get(n),e))return;const s=this._rootLView;UC(s[hn],s,r,n,e),this.previousInputValues.set(n,e),Rf(Ks(this._tNode.index,s))}}get injector(){return new to(this._tNode,this._rootLView)}destroy(){this.hostView.destroy()}onDestroy(n){this.hostView.onDestroy(n)}}function a0e(){const t=zs();q(Ot()[hn],t)}function Rn(t){let n=function Cz(t){return Object.getPrototypeOf(t.prototype).constructor}(t.type),e=!0;const i=[t];for(;n;){let r;if(Ia(t))r=n.\u0275cmp||n.\u0275dir;else{if(n.\u0275cmp)throw new kt(903,!1);r=n.\u0275dir}if(r){if(e){i.push(r);const a=t;a.inputs=l9(t.inputs),a.inputTransforms=l9(t.inputTransforms),a.declaredInputs=l9(t.declaredInputs),a.outputs=l9(t.outputs);const o=r.hostBindings;o&&u0e(t,o);const c=r.viewQuery,l=r.contentQueries;if(c&&c0e(t,c),l&&l0e(t,l),yo(t.inputs,r.inputs),yo(t.declaredInputs,r.declaredInputs),yo(t.outputs,r.outputs),null!==r.inputTransforms&&(null===a.inputTransforms&&(a.inputTransforms={}),yo(a.inputTransforms,r.inputTransforms)),Ia(r)&&r.data.animation){const u=t.data;u.animation=(u.animation||[]).concat(r.data.animation)}}const s=r.features;if(s)for(let a=0;a<s.length;a++){const o=s[a];o&&o.ngInherit&&o(t),o===Rn&&(e=!1)}}n=Object.getPrototypeOf(n)}!function o0e(t){let n=0,e=null;for(let i=t.length-1;i>=0;i--){const r=t[i];r.hostVars=n+=r.hostVars,r.hostAttrs=W0(r.hostAttrs,e=W0(e,r.hostAttrs))}}(i)}function l9(t){return t===V1?{}:t===$i?[]:t}function c0e(t,n){const e=t.viewQuery;t.viewQuery=e?(i,r)=>{n(i,r),e(i,r)}:n}function l0e(t,n){const e=t.contentQueries;t.contentQueries=e?(i,r,s)=>{n(i,r,s),e(i,r,s)}:n}function u0e(t,n){const e=t.hostBindings;t.hostBindings=e?(i,r)=>{n(i,r),e(i,r)}:n}function kz(t){const n=t.inputConfig,e={};for(const i in n)if(n.hasOwnProperty(i)){const r=n[i];Array.isArray(r)&&r[2]&&(e[i]=r[2])}t.inputTransforms=e}function u9(t){return!!jC(t)&&(Array.isArray(t)||!(t instanceof Map)&&Symbol.iterator in t)}function jC(t){return null!==t&&("function"==typeof t||"object"==typeof t)}function pc(t,n,e){return t[n]=e}function Vf(t,n){return t[n]}function Pa(t,n,e){return!Object.is(t[n],e)&&(t[n]=e,!0)}function d4(t,n,e,i){const r=Pa(t,n,e);return Pa(t,n+1,i)||r}function d9(t,n,e,i,r){const s=d4(t,n,e,i);return Pa(t,n+2,r)||s}function X1(t,n,e,i,r,s){const a=d4(t,n,e,i);return d4(t,n+2,r,s)||a}function pi(t,n,e,i){const r=Ot();return Pa(r,C3(),n)&&(Ri(),hc(ki(),r,t,n,e,i)),pi}function R6(t,n,e,i){return Pa(t,C3(),e)?n+Bn(e)+i:di}function B(t,n,e,i,r,s,a,o){const c=Ot(),l=Ri(),u=t+Ei,d=l.firstCreatePass?function L0e(t,n,e,i,r,s,a,o,c){const l=n.consts,u=D6(n,t,4,a||null,Da(l,o));HC(n,e,u,Da(l,c)),q(n,u);const d=u.tView=OC(2,u,i,r,s,n.directiveRegistry,n.pipeRegistry,null,n.schemas,l,null);return null!==n.queries&&(n.queries.template(n,u),d.queries=n.queries.embeddedTView(u)),u}(u,l,c,n,e,i,r,s,a):l.data[u];q1(d,!1);const h=Vz(l,c,d,t);M3()&&Bm(l,c,h,d),La(h,c),a9(c,c[u]=cz(h,c,h,d)),ec(d)&&PC(l,c,d),null!=a&&zC(c,d,o)}let Vz=function Fz(t,n,e,i){return ie(!0),n[ii].createComment("")};function St(t){return _3(function Nw(){return Nn.lFrame.contextLView}(),Ei+t)}function _(t,n,e){const i=Ot();return Pa(i,C3(),n)&&y1(Ri(),ki(),i,t,n,i[ii],e,!1),_}function KC(t,n,e,i,r){const a=r?"class":"style";UC(t,e,n.inputs[a],a,i)}function f(t,n,e,i){const r=Ot(),s=Ri(),a=Ei+t,o=r[ii],c=s.firstCreatePass?function H0e(t,n,e,i,r,s){const a=n.consts,c=D6(n,t,2,i,Da(a,r));return HC(n,e,c,Da(a,s)),null!==c.attrs&&o9(c,c.attrs,!1),null!==c.mergedAttrs&&o9(c,c.mergedAttrs,!0),null!==n.queries&&n.queries.elementStart(n,c),c}(a,s,r,n,e,i):s.data[a],l=Bz(s,r,c,o,n,t);r[a]=l;const u=ec(c);return q1(c,!0),tP(o,l,c),32!=(32&c.flags)&&M3()&&Bm(s,r,l,c),0===function rc(){return Nn.lFrame.elementDepthCount}()&&La(l,r),function Iw(){Nn.lFrame.elementDepthCount++}(),u&&(PC(s,r,c),LC(s,c,r)),null!==i&&zC(r,c),f}function m(){let t=zs();t4()?ac():(t=t.parent,q1(t,!1));const n=t;(function lf(t){return Nn.skipHydrationRootTNode===t})(n)&&function sc(){Nn.skipHydrationRootTNode=null}(),function b3(){Nn.lFrame.elementDepthCount--}();const e=Ri();return e.firstCreatePass&&(q(e,t),J7(t)&&e.queries.elementEnd(t)),null!=n.classesWithoutHost&&function vs(t){return 0!=(8&t.flags)}(n)&&KC(e,n,Ot(),n.classesWithoutHost,!0),null!=n.stylesWithoutHost&&function vr(t){return 0!=(16&t.flags)}(n)&&KC(e,n,Ot(),n.stylesWithoutHost,!1),m}function Se(t,n,e,i){return f(t,n,e,i),m(),Se}let Bz=(t,n,e,i,r,s)=>(ie(!0),Hm(i,r,function xm(){return Nn.lFrame.currentNamespace}()));function At(t,n,e){const i=Ot(),r=Ri(),s=t+Ei,a=r.firstCreatePass?function B0e(t,n,e,i,r){const s=n.consts,a=Da(s,i),o=D6(n,t,8,"ng-container",a);return null!==a&&o9(o,a,!0),HC(n,e,o,Da(s,r)),null!==n.queries&&n.queries.elementStart(n,o),o}(s,r,i,n,e):r.data[s];q1(a,!0);const o=Uz(r,i,a,t);return i[s]=o,M3()&&Bm(r,i,o,a),La(o,i),ec(a)&&(PC(r,i,a),LC(r,a,i)),null!=e&&zC(i,a),At}function It(){let t=zs();const n=Ri();return t4()?ac():(t=t.parent,q1(t,!1)),n.firstCreatePass&&(q(n,t),J7(t)&&n.queries.elementEnd(t)),It}function za(t,n,e){return At(t,n,e),It(),za}let Uz=(t,n,e,i)=>(ie(!0),Yw(n[ii],""));function Ct(){return Ot()}function $f(t){return!!t&&"function"==typeof t.then}function $z(t){return!!t&&"function"==typeof t.subscribe}function Ee(t,n,e,i){const r=Ot(),s=Ri(),a=zs();return function Wz(t,n,e,i,r,s,a){const o=ec(i),l=t.firstCreatePass&&dz(t),u=n[rs],d=uz(n);let h=!0;if(3&i.type||a){const D=ha(i,n),V=a?a(D):D,we=d.length,Ce=a?Fe=>a(rr(Fe[i.index])):i.index;let Ve=null;if(!a&&o&&(Ve=function j0e(t,n,e,i){const r=t.cleanup;if(null!=r)for(let s=0;s<r.length-1;s+=2){const a=r[s];if(a===e&&r[s+1]===i){const o=n[da],c=r[s+2];return o.length>c?o[c]:null}"string"==typeof a&&(s+=2)}return null}(t,n,r,i.index)),null!==Ve)(Ve.__ngLastListenerFn__||Ve).__ngNextListenerFn__=s,Ve.__ngLastListenerFn__=s,h=!1;else{s=Gz(i,n,u,s,!1);const Fe=e.listen(V,r,s);d.push(s,Fe),l&&l.push(r,Ce,we,we+1)}}else s=Gz(i,n,u,s,!1);const y=i.outputs;let I;if(h&&null!==y&&(I=y[r])){const D=I.length;if(D)for(let V=0;V<D;V+=2){const qe=n[I[V]][I[V+1]].subscribe(s),nt=d.length;d.push(s,qe),l&&l.push(r,i.index,nt,-(nt+1))}}}(s,r,r[ii],a,t,n,i),Ee}function qz(t,n,e,i){try{return ko(6,n,e),!1!==e(i)}catch(r){return hz(t,r),!1}finally{ko(7,n,e)}}function Gz(t,n,e,i,r){return function s(a){if(a===Function)return i;Rf(t.componentOffset>-1?Ks(t.index,n):n);let c=qz(n,e,i,a),l=s.__ngNextListenerFn__;for(;l;)c=qz(n,e,l,a)&&c,l=l.__ngNextListenerFn__;return r&&!1===c&&a.preventDefault(),c}}function O(t=1){return function r4(t){return(Nn.lFrame.contextLView=function lc(t,n){for(;t>0;)n=n[f3],t--;return n}(t,Nn.lFrame.contextLView))[rs]}(t)}function W0e(t,n){let e=null;const i=function mw(t){const n=t.attrs;if(null!=n){const e=n.indexOf(5);if(!(1&e))return n[e+1]}return null}(t);for(let r=0;r<n.length;r++){const s=n[r];if("*"!==s){if(null===i?ir(t,s,!0):gw(i,s))return r}else e=r}return e}function f4(t){const n=Ot()[Lr][Xr];if(!n.projection){const i=n.projection=yf(t?t.length:1,null),r=i.slice();let s=n.child;for(;null!==s;){const a=t?W0e(s,t):0;null!==a&&(r[a]?r[a].projectionNext=s:i[a]=s,r[a]=s),s=s.next}}}function ml(t,n=0,e){const i=Ot(),r=Ri(),s=D6(r,Ei+t,16,null,e||null);null===s.projection&&(s.projection=n),ac(),(!i[Za]||w3())&&32!=(32&s.flags)&&function Wce(t,n,e){JL(n[ii],0,n,e,Qw(t,e,n),GL(e.parent||n[Xr],e,n))}(r,i,s)}function jf(t,n,e){return h4(t,"",n,"",e),jf}function h4(t,n,e,i,r){const s=Ot(),a=R6(s,n,e,i);return a!==di&&y1(Ri(),ki(),s,t,a,s[ii],r,!1),h4}function m9(t,n){return t<<17|n<<2}function E3(t){return t>>17&32767}function XC(t){return 2|t}function p4(t){return(131068&t)>>2}function QC(t,n){return-131069&t|n<<2}function JC(t){return 1|t}function nO(t,n,e,i,r){const s=t[e+1],a=null===n;let o=i?E3(s):p4(s),c=!1;for(;0!==o&&(!1===c||a);){const u=t[o+1];X0e(t[o],n)&&(c=!0,t[o+1]=i?JC(u):XC(u)),o=i?E3(u):p4(u)}c&&(t[e+1]=i?XC(s):JC(s))}function X0e(t,n){return null===t||null==n||(Array.isArray(t)?t[1]:t)===n||!(!Array.isArray(t)||"string"!=typeof n)&&g6(t,n)>=0}const Vs={textEnd:0,key:0,keyEnd:0,value:0,valueEnd:0};function iO(t){return t.substring(Vs.key,Vs.keyEnd)}function rO(t,n){const e=Vs.textEnd;return e===n?-1:(n=Vs.keyEnd=function t4e(t,n,e){for(;n<e&&t.charCodeAt(n)>32;)n++;return n}(t,Vs.key=n,e),B6(t,n,e))}function B6(t,n,e){for(;n<e&&t.charCodeAt(n)<=32;)n++;return n}function no(t,n,e){return N2(t,n,e,!1),no}function Li(t,n){return N2(t,n,null,!0),Li}function io(t){!function R2(t,n,e,i){const r=Ri(),s=f1(2);r.firstUpdatePass&&uO(r,null,s,i);const a=Ot();if(e!==di&&Pa(a,s,e)){const o=r.data[ma()];if(pO(o,i)&&!lO(r,s)){let c=i?o.classesWithoutHost:o.stylesWithoutHost;null!==c&&(e=nr(c,e||"")),KC(r,o,a,e,i)}else!function d4e(t,n,e,i,r,s,a,o){r===di&&(r=$i);let c=0,l=0,u=0<r.length?r[0]:null,d=0<s.length?s[0]:null;for(;null!==u||null!==d;){const h=c<r.length?r[c+1]:void 0,y=l<s.length?s[l+1]:void 0;let D,I=null;u===d?(c+=2,l+=2,h!==y&&(I=d,D=y)):null===d||null!==u&&u<d?(c+=2,I=u):(l+=2,I=d,D=y),null!==I&&fO(t,n,e,i,I,D,a,o),u=c<r.length?r[c]:null,d=l<s.length?s[l]:null}}(r,o,a,a[ii],a[s+1],a[s+1]=function l4e(t,n,e){if(null==e||""===e)return $i;const i=[],r=g1(e);if(Array.isArray(r))for(let s=0;s<r.length;s++)t(i,r[s],!0);else if("object"==typeof r)for(const s in r)r.hasOwnProperty(s)&&t(i,s,r[s]);else"string"==typeof r&&n(i,r);return i}(t,n,e),i,s)}}(u4e,gc,t,!0)}function gc(t,n){for(let e=function J0e(t){return function aO(t){Vs.key=0,Vs.keyEnd=0,Vs.value=0,Vs.valueEnd=0,Vs.textEnd=t.length}(t),rO(t,B6(t,0,Vs.textEnd))}(n);e>=0;e=rO(n,e))m1(t,iO(n),!0)}function N2(t,n,e,i){const r=Ot(),s=Ri(),a=f1(2);s.firstUpdatePass&&uO(s,t,a,i),n!==di&&Pa(r,a,n)&&fO(s,s.data[ma()],r,r[ii],t,r[a+1]=function f4e(t,n){return null==t||""===t||("string"==typeof n?t+=n:"object"==typeof t&&(t=ni(g1(t)))),t}(n,e),i,a)}function lO(t,n){return n>=t.expandoStartIndex}function uO(t,n,e,i){const r=t.data;if(null===r[e+1]){const s=r[ma()],a=lO(t,e);pO(s,i)&&null===n&&!a&&(n=!1),n=function s4e(t,n,e,i){const r=I2(t);let s=i?n.residualClasses:n.residualStyles;if(null===r)0===(i?n.classBindings:n.styleBindings)&&(e=Wf(e=ex(null,t,n,e,i),n.attrs,i),s=null);else{const a=n.directiveStylingLast;if(-1===a||t[a]!==r)if(e=ex(r,t,n,e,i),null===s){let c=function a4e(t,n,e){const i=e?n.classBindings:n.styleBindings;if(0!==p4(i))return t[E3(i)]}(t,n,i);void 0!==c&&Array.isArray(c)&&(c=ex(null,t,n,c[1],i),c=Wf(c,n.attrs,i),function o4e(t,n,e,i){t[E3(e?n.classBindings:n.styleBindings)]=i}(t,n,i,c))}else s=function c4e(t,n,e){let i;const r=n.directiveEnd;for(let s=1+n.directiveStylingLast;s<r;s++)i=Wf(i,t[s].hostAttrs,e);return Wf(i,n.attrs,e)}(t,n,i)}return void 0!==s&&(i?n.residualClasses=s:n.residualStyles=s),e}(r,s,n,i),function Y0e(t,n,e,i,r,s){let a=s?n.classBindings:n.styleBindings,o=E3(a),c=p4(a);t[i]=e;let u,l=!1;if(Array.isArray(e)?(u=e[1],(null===u||g6(e,u)>0)&&(l=!0)):u=e,r)if(0!==c){const h=E3(t[o+1]);t[i+1]=m9(h,o),0!==h&&(t[h+1]=QC(t[h+1],i)),t[o+1]=function G0e(t,n){return 131071&t|n<<17}(t[o+1],i)}else t[i+1]=m9(o,0),0!==o&&(t[o+1]=QC(t[o+1],i)),o=i;else t[i+1]=m9(c,0),0===o?o=i:t[c+1]=QC(t[c+1],i),c=i;l&&(t[i+1]=XC(t[i+1])),nO(t,u,i,!0),nO(t,u,i,!1),function K0e(t,n,e,i,r){const s=r?t.residualClasses:t.residualStyles;null!=s&&"string"==typeof n&&g6(s,n)>=0&&(e[i+1]=JC(e[i+1]))}(n,u,t,i,s),a=m9(o,c),s?n.classBindings=a:n.styleBindings=a}(r,s,n,e,a,i)}}function ex(t,n,e,i,r){let s=null;const a=e.directiveEnd;let o=e.directiveStylingLast;for(-1===o?o=e.directiveStart:o++;o<a&&(s=n[o],i=Wf(i,s.hostAttrs,r),s!==t);)o++;return null!==t&&(e.directiveStylingLast=o),i}function Wf(t,n,e){const i=e?1:2;let r=-1;if(null!==n)for(let s=0;s<n.length;s++){const a=n[s];"number"==typeof a?r=a:r===i&&(Array.isArray(t)||(t=void 0===t?[]:["",t]),m1(t,a,!!e||n[++s]))}return void 0===t?null:t}function u4e(t,n,e){const i=String(n);""!==i&&!i.includes(" ")&&m1(t,i,e)}function fO(t,n,e,i,r,s,a,o){if(!(3&n.type))return;const c=t.data,l=c[o+1],u=function Z0e(t){return 1==(1&t)}(l)?hO(c,n,e,r,p4(l),a):void 0;g9(u)||(g9(s)||function q0e(t){return 2==(2&t)}(l)&&(s=hO(c,null,e,r,o,a)),function Gce(t,n,e,i,r){if(n)r?t.addClass(e,i):t.removeClass(e,i);else{let s=-1===i.indexOf("-")?void 0:S3.DashCase;null==r?t.removeStyle(e,i,s):("string"==typeof r&&r.endsWith("!important")&&(r=r.slice(0,-10),s|=S3.Important),t.setStyle(e,i,r,s))}}(i,a,r6(ma(),e),r,s))}function hO(t,n,e,i,r,s){const a=null===n;let o;for(;r>0;){const c=t[r],l=Array.isArray(c),u=l?c[1]:c,d=null===u;let h=e[r+1];h===di&&(h=d?$i:void 0);let y=d?Vw(h,i):u===i?h:void 0;if(l&&!g9(y)&&(y=Vw(c,i)),g9(y)&&(o=y,a))return o;const I=t[r+1];r=a?E3(I):p4(I)}if(null!==n){let c=s?n.residualClasses:n.residualStyles;null!=c&&(o=Vw(c,i))}return o}function g9(t){return void 0!==t}function pO(t,n){return 0!=(t.flags&(n?8:16))}function P(t,n=""){const e=Ot(),i=Ri(),r=t+Ei,s=i.firstCreatePass?D6(i,r,1,n,null):i.data[r],a=mO(i,e,s,n,t);e[r]=a,M3()&&Bm(i,e,a,s),q1(s,!1)}let mO=(t,n,e,i,r)=>(ie(!0),function Om(t,n){return t.createText(n)}(n[ii],i));function un(t){return rt("",t,""),un}function rt(t,n,e){const i=Ot(),r=R6(i,t,n,e);return r!==di&&pl(i,ma(),r),rt}function Do(t,n,e,i,r){const s=Ot(),a=function L6(t,n,e,i,r,s){const o=d4(t,Na(),e,r);return f1(2),o?n+Bn(e)+i+Bn(r)+s:di}(s,t,n,e,i,r);return a!==di&&pl(s,ma(),a),Do}function Qs(t,n,e,i,r,s,a){const o=Ot(),c=function P6(t,n,e,i,r,s,a,o){const l=d9(t,Na(),e,r,a);return f1(3),l?n+Bn(e)+i+Bn(r)+s+Bn(a)+o:di}(o,t,n,e,i,r,s,a);return c!==di&&pl(o,ma(),c),Qs}function _1(t,n,e){const i=Ot();return Pa(i,C3(),n)&&y1(Ri(),ki(),i,t,n,i[ii],e,!0),_1}function tx(t,n,e){const i=Ot();if(Pa(i,C3(),n)){const s=Ri(),a=ki();y1(s,a,i,t,n,fz(I2(s.data),a,i),e,!0)}return tx}const m4=void 0;var L4e=["en",[["a","p"],["AM","PM"],m4],[["AM","PM"],m4,m4],[["S","M","T","W","T","F","S"],["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],["Su","Mo","Tu","We","Th","Fr","Sa"]],m4,[["J","F","M","A","M","J","J","A","S","O","N","D"],["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],["January","February","March","April","May","June","July","August","September","October","November","December"]],m4,[["B","A"],["BC","AD"],["Before Christ","Anno Domini"]],0,[6,0],["M/d/yy","MMM d, y","MMMM d, y","EEEE, MMMM d, y"],["h:mm a","h:mm:ss a","h:mm:ss a z","h:mm:ss a zzzz"],["{1}, {0}",m4,"{1} 'at' {0}",m4],[".",",",";","%","+","-","E","\xd7","\u2030","\u221e","NaN",":"],["#,##0.###","#,##0%","\xa4#,##0.00","#E0"],"USD","$","US Dollar",{},"ltr",function R4e(t){const e=Math.floor(Math.abs(t)),i=t.toString().replace(/^[^.]*\.?/,"").length;return 1===e&&0===i?1:5}];let U6={};function ro(t){const n=function P4e(t){return t.toLowerCase().replace(/_/g,"-")}(t);let e=NO(n);if(e)return e;const i=n.split("-")[0];if(e=NO(i),e)return e;if("en"===i)return L4e;throw new kt(701,!1)}function NO(t){return t in U6||(U6[t]=Mr.ng&&Mr.ng.common&&Mr.ng.common.locales&&Mr.ng.common.locales[t]),U6[t]}var zr=function(t){return t[t.LocaleId=0]="LocaleId",t[t.DayPeriodsFormat=1]="DayPeriodsFormat",t[t.DayPeriodsStandalone=2]="DayPeriodsStandalone",t[t.DaysFormat=3]="DaysFormat",t[t.DaysStandalone=4]="DaysStandalone",t[t.MonthsFormat=5]="MonthsFormat",t[t.MonthsStandalone=6]="MonthsStandalone",t[t.Eras=7]="Eras",t[t.FirstDayOfWeek=8]="FirstDayOfWeek",t[t.WeekendRange=9]="WeekendRange",t[t.DateFormat=10]="DateFormat",t[t.TimeFormat=11]="TimeFormat",t[t.DateTimeFormat=12]="DateTimeFormat",t[t.NumberSymbols=13]="NumberSymbols",t[t.NumberFormats=14]="NumberFormats",t[t.CurrencyCode=15]="CurrencyCode",t[t.CurrencySymbol=16]="CurrencySymbol",t[t.CurrencyName=17]="CurrencyName",t[t.Currencies=18]="Currencies",t[t.Directionality=19]="Directionality",t[t.PluralCase=20]="PluralCase",t[t.ExtraData=21]="ExtraData",t}(zr||{});const $6="en-US";let RO=$6;function rx(t,n,e,i,r){if(t=fn(t),Array.isArray(t))for(let s=0;s<t.length;s++)rx(t[s],n,e,i,r);else{const s=Ri(),a=Ot(),o=zs();let c=c4(t)?t:fn(t.provide);const l=bP(t),u=1048575&o.providerIndexes,d=o.directiveStart,h=o.providerIndexes>>20;if(c4(t)||!t.multi){const y=new Wi(l,r,Te),I=ax(c,n,r?u:u+h,d);-1===I?(zw(km(o,a),s,c),sx(s,t,n.length),n.push(c),o.directiveStart++,o.directiveEnd++,r&&(o.providerIndexes+=1048576),e.push(y),a.push(y)):(e[I]=y,a[I]=y)}else{const y=ax(c,n,u+h,d),I=ax(c,n,u,u+h),V=I>=0&&e[I];if(r&&!V||!r&&!(y>=0&&e[y])){zw(km(o,a),s,c);const we=function Nue(t,n,e,i,r){const s=new Wi(t,e,Te);return s.multi=[],s.index=n,s.componentProviders=0,rH(s,r,i&&!e),s}(r?Due:Iue,e.length,r,i,l);!r&&V&&(e[I].providerFactory=we),sx(s,t,n.length,0),n.push(c),o.directiveStart++,o.directiveEnd++,r&&(o.providerIndexes+=1048576),e.push(we),a.push(we)}else sx(s,t,y>-1?y:I,rH(e[r?I:y],l,!r&&i));!r&&i&&V&&e[I].componentProviders++}}}function sx(t,n,e,i){const r=c4(n),s=function kle(t){return!!t.useClass}(n);if(r||s){const c=(s?fn(n.useClass):n).prototype.ngOnDestroy;if(c){const l=t.destroyHooks||(t.destroyHooks=[]);if(!r&&n.multi){const u=l.indexOf(e);-1===u?l.push(e,[i,c]):l[u+1].push(i,c)}else l.push(e,c)}}}function rH(t,n,e){return e&&t.componentProviders++,t.multi.push(n)-1}function ax(t,n,e,i){for(let r=e;r<i;r++)if(n[r]===t)return r;return-1}function Iue(t,n,e,i){return ox(this.multi,[])}function Due(t,n,e,i){const r=this.multi;let s;if(this.providerFactory){const a=this.providerFactory.componentProviders,o=s4(e,e[hn],this.providerFactory.index,i);s=o.slice(0,a),ox(r,s);for(let c=a;c<o.length;c++)s.push(o[c])}else s=[],ox(r,s);return s}function ox(t,n){for(let e=0;e<t.length;e++)n.push((0,t[e])());return n}function ci(t,n=[]){return e=>{e.providersResolver=(i,r)=>function Aue(t,n,e){const i=Ri();if(i.firstCreatePass){const r=Ia(t);rx(e,i.data,i.blueprint,r,!0),rx(n,i.data,i.blueprint,r,!1)}}(i,r?r(t):t,n)}}class g4{}class sH{}class cx extends g4{constructor(n,e,i){super(),this._parent=e,this._bootstrapComponents=[],this.destroyCbs=[],this.componentFactoryResolver=new bz(this);const r=Ga(n);this._bootstrapComponents=hl(r.bootstrap),this._r3Injector=NP(n,e,[{provide:g4,useValue:this},{provide:Nf,useValue:this.componentFactoryResolver},...i],ni(n),new Set(["environment"])),this._r3Injector.resolveInjectorInitializers(),this.instance=this._r3Injector.get(n)}get injector(){return this._r3Injector}destroy(){const n=this._r3Injector;!n.destroyed&&n.destroy(),this.destroyCbs.forEach(e=>e()),this.destroyCbs=null}onDestroy(n){this.destroyCbs.push(n)}}class lx extends sH{constructor(n){super(),this.moduleType=n}create(n){return new cx(this.moduleType,n,[])}}class aH extends g4{constructor(n){super(),this.componentFactoryResolver=new bz(this),this.instance=null;const e=new C6([...n.providers,{provide:g4,useValue:this},{provide:Nf,useValue:this.componentFactoryResolver}],n.parent||Km(),n.debugName,new Set(["environment"]));this.injector=e,n.runEnvironmentInitializers&&e.resolveInjectorInitializers()}destroy(){this.injector.destroy()}onDestroy(n){this.injector.onDestroy(n)}}function ux(t,n,e=null){return new aH({providers:t,parent:n,debugName:e,runEnvironmentInitializers:!0}).injector}let Pue=(()=>{class t{constructor(e){this._injector=e,this.cachedInjectors=new Map}getOrCreateStandaloneInjector(e){if(!e.standalone)return null;if(!this.cachedInjectors.has(e)){const i=gP(0,e.type),r=i.length>0?ux([i],this._injector,`Standalone[${e.type.name}]`):null;this.cachedInjectors.set(e,r)}return this.cachedInjectors.get(e)}ngOnDestroy(){try{for(const e of this.cachedInjectors.values())null!==e&&e.destroy()}finally{this.cachedInjectors.clear()}}static#e=this.\u0275prov=Pt({token:t,providedIn:"environment",factory:()=>new t(gt(Ao))})}return t})();function Ro(t){t.getStandaloneInjector=n=>n.get(Pue).getOrCreateStandaloneInjector(t)}function Ai(t,n,e){const i=pa()+t,r=Ot();return r[i]===di?pc(r,i,e?n.call(e):n()):Vf(r,i)}function Ut(t,n,e,i){return hH(Ot(),pa(),t,n,e,i)}function pn(t,n,e,i,r){return pH(Ot(),pa(),t,n,e,i,r)}function Ii(t,n,e,i,r,s){return mH(Ot(),pa(),t,n,e,i,r,s)}function vc(t,n,e,i,r,s,a){return function gH(t,n,e,i,r,s,a,o,c){const l=n+e;return X1(t,l,r,s,a,o)?pc(t,l+4,c?i.call(c,r,s,a,o):i(r,s,a,o)):Qf(t,l+4)}(Ot(),pa(),t,n,e,i,r,s,a)}function ys(t,n,e,i,r,s,a,o){const c=pa()+t,l=Ot(),u=X1(l,c,e,i,r,s);return Pa(l,c+4,a)||u?pc(l,c+5,o?n.call(o,e,i,r,s,a):n(e,i,r,s,a)):Vf(l,c+5)}function Qf(t,n){const e=t[n];return e===di?void 0:e}function hH(t,n,e,i,r,s){const a=n+e;return Pa(t,a,r)?pc(t,a+1,s?i.call(s,r):i(r)):Qf(t,a+1)}function pH(t,n,e,i,r,s,a){const o=n+e;return d4(t,o,r,s)?pc(t,o+2,a?i.call(a,r,s):i(r,s)):Qf(t,o+2)}function mH(t,n,e,i,r,s,a,o){const c=n+e;return d9(t,c,r,s,a)?pc(t,c+3,o?i.call(o,r,s,a):i(r,s,a)):Qf(t,c+3)}function ye(t,n){const e=Ri();let i;const r=t+Ei;e.firstCreatePass?(i=function Zue(t,n){if(n)for(let e=n.length-1;e>=0;e--){const i=n[e];if(t===i.name)return i}}(n,e.pipeRegistry),e.data[r]=i,i.onDestroy&&(e.destroyHooks??=[]).push(r,i.onDestroy)):i=e.data[r];const s=i.factory||(i.factory=xo(i.type)),o=Ma(Te);try{const c=Mm(!1),l=s();return Mm(c),function O0e(t,n,e,i){e>=t.data.length&&(t.data[e]=null,t.blueprint[e]=null),n[e]=i}(e,Ot(),r,l),l}finally{Ma(o)}}function ut(t,n,e){const i=t+Ei,r=Ot(),s=_3(r,i);return Jf(r,i)?hH(r,pa(),n,s.transform,e,s):s.transform(e)}function tt(t,n,e,i){const r=t+Ei,s=Ot(),a=_3(s,r);return Jf(s,r)?pH(s,pa(),n,a.transform,e,i,a):a.transform(e,i)}function L2(t,n,e,i,r){const s=t+Ei,a=Ot(),o=_3(a,s);return Jf(a,s)?mH(a,pa(),n,o.transform,e,i,r,o):o.transform(e,i,r)}function Ir(t,n,e){const i=t+Ei,r=Ot(),s=_3(r,i);return Jf(r,i)?function vH(t,n,e,i,r,s){let a=n+e,o=!1;for(let c=0;c<r.length;c++)Pa(t,a++,r[c])&&(o=!0);return o?pc(t,a,i.apply(s,r)):Qf(t,a)}(r,pa(),n,s.transform,e,s):s.transform.apply(s,e)}function Jf(t,n){return t[hn].data[n].pure}function Kue(){return this._results[Symbol.iterator]()}class fx{static#e=Symbol.iterator;get changes(){return this._changes||(this._changes=new Ht)}constructor(n=!1){this._emitDistinctChangesOnly=n,this.dirty=!0,this._results=[],this._changesDetected=!1,this._changes=null,this.length=0,this.first=void 0,this.last=void 0;const e=fx.prototype;e[Symbol.iterator]||(e[Symbol.iterator]=Kue)}get(n){return this._results[n]}map(n){return this._results.map(n)}filter(n){return this._results.filter(n)}find(n){return this._results.find(n)}reduce(n,e){return this._results.reduce(n,e)}forEach(n){this._results.forEach(n)}some(n){return this._results.some(n)}toArray(){return this._results.slice()}toString(){return this._results.toString()}reset(n,e){const i=this;i.dirty=!1;const r=function K1(t){return t.flat(Number.POSITIVE_INFINITY)}(n);(this._changesDetected=!function K2e(t,n,e){if(t.length!==n.length)return!1;for(let i=0;i<t.length;i++){let r=t[i],s=n[i];if(e&&(r=e(r),s=e(s)),s!==r)return!1}return!0}(i._results,r,e))&&(i._results=r,i.length=r.length,i.last=r[this.length-1],i.first=r[0])}notifyOnChanges(){this._changes&&(this._changesDetected||!this._emitDistinctChangesOnly)&&this._changes.emit(this)}setDirty(){this.dirty=!0}destroy(){this.changes.complete(),this.changes.unsubscribe()}}function Que(t,n,e,i=!0){const r=n[hn];if(function Vce(t,n,e,i){const r=Zs+i,s=e.length;i>0&&(e[r-1][Ts]=n),i<s-Zs?(n[Ts]=e[r],yL(e,Zs+i,n)):(e.push(n),n[Ts]=null),n[fr]=e;const a=n[u1];null!==a&&e!==a&&function Fce(t,n){const e=t[nl];n[Lr]!==n[fr][fr][Lr]&&(t[_w]=!0),null===e?t[nl]=[n]:e.push(n)}(a,n);const o=n[F1];null!==o&&o.insertView(t),n[ui]|=128}(r,n,t,e),i){const s=eC(e,t),a=n[ii],o=Fm(a,t[T2]);null!==o&&function zce(t,n,e,i,r,s){i[Kr]=r,i[Xr]=n,Mf(t,i,e,1,r,s)}(r,t[Xr],a,n,o,s)}}let sr=(()=>{class t{static#e=this.__NG_ELEMENT_ID__=t6e}return t})();const Jue=sr,e6e=class extends Jue{constructor(n,e,i){super(),this._declarationLView=n,this._declarationTContainer=e,this.elementRef=i}get ssrId(){return this._declarationTContainer.tView?.ssrId||null}createEmbeddedView(n,e){return this.createEmbeddedViewImpl(n,e)}createEmbeddedViewImpl(n,e,i){const r=function Xue(t,n,e,i){const r=n.tView,o=s9(t,r,e,4096&t[ui]?4096:16,null,n,null,null,null,i?.injector??null,i?.hydrationInfo??null);o[u1]=t[n.index];const l=t[F1];return null!==l&&(o[F1]=l.createEmbeddedView(r)),$C(r,o,e),o}(this._declarationLView,this._declarationTContainer,n,{injector:e,hydrationInfo:i});return new zf(r)}};function t6e(){return w9(zs(),Ot())}function w9(t,n){return 4&t.type?new e6e(n,t,k6(t,n)):null}let ga=(()=>{class t{static#e=this.__NG_ELEMENT_ID__=o6e}return t})();function o6e(){return TH(zs(),Ot())}const c6e=ga,CH=class extends c6e{constructor(n,e,i){super(),this._lContainer=n,this._hostTNode=e,this._hostLView=i}get element(){return k6(this._hostTNode,this._hostLView)}get injector(){return new to(this._hostTNode,this._hostLView)}get parentInjector(){const n=Sm(this._hostTNode,this._hostLView);if(Os(n)){const e=mf(n,this._hostLView),i=Vr(n);return new to(e[hn].data[i+8],e)}return new to(null,this._hostLView)}clear(){for(;this.length>0;)this.remove(this.length-1)}get(n){const e=xH(this._lContainer);return null!==e&&e[n]||null}get length(){return this._lContainer.length-Zs}createEmbeddedView(n,e,i){let r,s;"number"==typeof i?r=i:null!=i&&(r=i.index,s=i.injector);const o=n.createEmbeddedViewImpl(e||{},s,null);return this.insertImpl(o,r,false),o}createComponent(n,e,i,r,s){const a=n&&!function vf(t){return"function"==typeof t}(n);let o;if(a)o=e;else{const D=e||{};o=D.index,i=D.injector,r=D.projectableNodes,s=D.environmentInjector||D.ngModuleRef}const c=a?n:new Of(Si(n)),l=i||this.parentInjector;if(!s&&null==c.ngModule){const V=(a?l:this.parentInjector).get(Ao,null);V&&(s=V)}Si(c.componentType??{});const y=c.create(l,r,null,s);return this.insertImpl(y.hostView,o,false),y}insert(n,e){return this.insertImpl(n,e,!1)}insertImpl(n,e,i){const r=n._lView;if(function s6(t){return Aa(t[fr])}(r)){const c=this.indexOf(n);if(-1!==c)this.detach(c);else{const l=r[fr],u=new CH(l,l[Xr],l[fr]);u.detach(u.indexOf(n))}}const a=this._adjustIndex(e),o=this._lContainer;return Que(o,r,a,!i),n.attachToViewContainerRef(),yL(hx(o),a,n),n}move(n,e){return this.insert(n,e)}indexOf(n){const e=xH(this._lContainer);return null!==e?e.indexOf(n):-1}remove(n){const e=this._adjustIndex(n,-1),i=Vm(this._lContainer,e);i&&(Am(hx(this._lContainer),e),Kw(i[hn],i))}detach(n){const e=this._adjustIndex(n,-1),i=Vm(this._lContainer,e);return i&&null!=Am(hx(this._lContainer),e)?new zf(i):null}_adjustIndex(n,e=0){return n??this.length+e}};function xH(t){return t[8]}function hx(t){return t[8]||(t[8]=[])}function TH(t,n){let e;const i=n[t.index];return Aa(i)?e=i:(e=cz(i,n,null,t),n[t.index]=e,a9(n,e)),MH(e,n,t,i),new CH(e,t,n)}let MH=function kH(t,n,e,i){if(t[T2])return;let r;r=8&e.type?rr(i):function l6e(t,n){const e=t[ii],i=e.createComment(""),r=ha(n,t);return a4(e,Fm(e,r),i,function jce(t,n){return t.nextSibling(n)}(e,r),!1),i}(n,e),t[T2]=r};class px{constructor(n){this.queryList=n,this.matches=null}clone(){return new px(this.queryList)}setDirty(){this.queryList.setDirty()}}class mx{constructor(n=[]){this.queries=n}createEmbeddedView(n){const e=n.queries;if(null!==e){const i=null!==n.contentQueries?n.contentQueries[0]:e.length,r=[];for(let s=0;s<i;s++){const a=e.getByIndex(s);r.push(this.queries[a.indexInDeclarationView].clone())}return new mx(r)}return null}insertView(n){this.dirtyQueriesWithMatches(n)}detachView(n){this.dirtyQueriesWithMatches(n)}dirtyQueriesWithMatches(n){for(let e=0;e<this.queries.length;e++)null!==DH(n,e).matches&&this.queries[e].setDirty()}}class SH{constructor(n,e,i=null){this.predicate=n,this.flags=e,this.read=i}}class gx{constructor(n=[]){this.queries=n}elementStart(n,e){for(let i=0;i<this.queries.length;i++)this.queries[i].elementStart(n,e)}elementEnd(n){for(let e=0;e<this.queries.length;e++)this.queries[e].elementEnd(n)}embeddedTView(n){let e=null;for(let i=0;i<this.length;i++){const r=null!==e?e.length:0,s=this.getByIndex(i).embeddedTView(n,r);s&&(s.indexInDeclarationView=i,null!==e?e.push(s):e=[s])}return null!==e?new gx(e):null}template(n,e){for(let i=0;i<this.queries.length;i++)this.queries[i].template(n,e)}getByIndex(n){return this.queries[n]}get length(){return this.queries.length}track(n){this.queries.push(n)}}class vx{constructor(n,e=-1){this.metadata=n,this.matches=null,this.indexInDeclarationView=-1,this.crossesNgTemplate=!1,this._appliesToNextNode=!0,this._declarationNodeIndex=e}elementStart(n,e){this.isApplyingToNode(e)&&this.matchTNode(n,e)}elementEnd(n){this._declarationNodeIndex===n.index&&(this._appliesToNextNode=!1)}template(n,e){this.elementStart(n,e)}embeddedTView(n,e){return this.isApplyingToNode(n)?(this.crossesNgTemplate=!0,this.addMatch(-n.index,e),new vx(this.metadata)):null}isApplyingToNode(n){if(this._appliesToNextNode&&1!=(1&this.metadata.flags)){const e=this._declarationNodeIndex;let i=n.parent;for(;null!==i&&8&i.type&&i.index!==e;)i=i.parent;return e===(null!==i?i.index:-1)}return this._appliesToNextNode}matchTNode(n,e){const i=this.metadata.predicate;if(Array.isArray(i))for(let r=0;r<i.length;r++){const s=i[r];this.matchTNodeWithReadOption(n,e,f6e(e,s)),this.matchTNodeWithReadOption(n,e,Em(e,n,s,!1,!1))}else i===sr?4&e.type&&this.matchTNodeWithReadOption(n,e,-1):this.matchTNodeWithReadOption(n,e,Em(e,n,i,!1,!1))}matchTNodeWithReadOption(n,e,i){if(null!==i){const r=this.metadata.read;if(null!==r)if(r===$n||r===ga||r===sr&&4&e.type)this.addMatch(e.index,-2);else{const s=Em(e,n,r,!1,!1);null!==s&&this.addMatch(e.index,s)}else this.addMatch(e.index,i)}}addMatch(n,e){null===this.matches?this.matches=[n,e]:this.matches.push(n,e)}}function f6e(t,n){const e=t.localNames;if(null!==e)for(let i=0;i<e.length;i+=2)if(e[i]===n)return e[i+1];return null}function p6e(t,n,e,i){return-1===e?function h6e(t,n){return 11&t.type?k6(t,n):4&t.type?w9(t,n):null}(n,t):-2===e?function m6e(t,n,e){return e===$n?k6(n,t):e===sr?w9(n,t):e===ga?TH(n,t):void 0}(t,n,i):s4(t,t[hn],e,n)}function EH(t,n,e,i){const r=n[F1].queries[i];if(null===r.matches){const s=t.data,a=e.matches,o=[];for(let c=0;c<a.length;c+=2){const l=a[c];o.push(l<0?null:p6e(n,s[l],a[c+1],e.metadata.read))}r.matches=o}return r.matches}function yx(t,n,e,i){const r=t.queries.getByIndex(e),s=r.matches;if(null!==s){const a=EH(t,n,r,e);for(let o=0;o<s.length;o+=2){const c=s[o];if(c>0)i.push(a[o/2]);else{const l=s[o+1],u=n[-c];for(let d=Zs;d<u.length;d++){const h=u[d];h[u1]===h[fr]&&yx(h[hn],h,l,i)}if(null!==u[nl]){const d=u[nl];for(let h=0;h<d.length;h++){const y=d[h];yx(y[hn],y,l,i)}}}}}return i}function qt(t){const n=Ot(),e=Ri(),i=h1();ff(i+1);const r=DH(e,i);if(t.dirty&&function ll(t){return 4==(4&t[ui])}(n)===(2==(2&r.metadata.flags))){if(null===r.matches)t.reset([]);else{const s=r.crossesNgTemplate?yx(e,n,i,[]):EH(e,n,r,i);t.reset(s,Gle),t.notifyOnChanges()}return!0}return!1}function Cn(t,n,e){const i=Ri();i.firstCreatePass&&(IH(i,new SH(t,n,e),-1),2==(2&n)&&(i.staticViewQueries=!0)),AH(i,Ot(),n)}function ar(t,n,e,i){const r=Ri();if(r.firstCreatePass){const s=zs();IH(r,new SH(n,e,i),s.index),function v6e(t,n){const e=t.contentQueries||(t.contentQueries=[]);n!==(e.length?e[e.length-1]:-1)&&e.push(t.queries.length-1,n)}(r,t),2==(2&e)&&(r.staticContentQueries=!0)}AH(r,Ot(),e)}function Gt(){return function g6e(t,n){return t[F1].queries[n].queryList}(Ot(),h1())}function AH(t,n,e){const i=new fx(4==(4&e));(function M3e(t,n,e,i){const r=uz(n);r.push(e),t.firstCreatePass&&dz(t).push(i,r.length-1)})(t,n,i,i.destroy),null===n[F1]&&(n[F1]=new mx),n[F1].queries.push(new px(i))}function IH(t,n,e){null===t.queries&&(t.queries=new gx),t.queries.track(new vx(n,e))}function DH(t,n){return t.queries.getByIndex(n)}function Dt(t,n){return w9(t,n)}const Tx=new Jt("Application Initializer");let Mx=(()=>{class t{constructor(){this.initialized=!1,this.done=!1,this.donePromise=new Promise((e,i)=>{this.resolve=e,this.reject=i}),this.appInits=Kt(Tx,{optional:!0})??[]}runInitializers(){if(this.initialized)return;const e=[];for(const r of this.appInits){const s=r();if($f(s))e.push(s);else if($z(s)){const a=new Promise((o,c)=>{s.subscribe({complete:o,error:c})});e.push(a)}}const i=()=>{this.done=!0,this.resolve()};Promise.all(e).then(()=>{i()}).catch(r=>{this.reject(r)}),0===e.length&&i(),this.initialized=!0}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),ZH=(()=>{class t{log(e){console.log(e)}warn(e){console.warn(e)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"platform"})}return t})();const Q1=new Jt("LocaleId",{providedIn:"root",factory:()=>Kt(Q1,Mi.Optional|Mi.SkipSelf)||function H6e(){return typeof $localize<"u"&&$localize.locale||$6}()});let YH=(()=>{class t{constructor(){this.taskId=0,this.pendingTasks=new Set,this.hasPendingTasks=new Vn(!1)}add(){this.hasPendingTasks.next(!0);const e=this.taskId++;return this.pendingTasks.add(e),e}remove(e){this.pendingTasks.delete(e),0===this.pendingTasks.size&&this.hasPendingTasks.next(!1)}ngOnDestroy(){this.pendingTasks.clear(),this.hasPendingTasks.next(!1)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();class B6e{constructor(n,e){this.ngModuleFactory=n,this.componentFactories=e}}let KH=(()=>{class t{compileModuleSync(e){return new lx(e)}compileModuleAsync(e){return Promise.resolve(this.compileModuleSync(e))}compileModuleAndAllComponentsSync(e){const i=this.compileModuleSync(e),s=hl(Ga(e).declarations).reduce((a,o)=>{const c=Si(o);return c&&a.push(new Of(c)),a},[]);return new B6e(i,s)}compileModuleAndAllComponentsAsync(e){return Promise.resolve(this.compileModuleAndAllComponentsSync(e))}clearCache(){}clearCacheFor(e){}getModuleId(e){}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();const eV=new Jt(""),M9=new Jt("");let Ix,Ex=(()=>{class t{constructor(e,i,r){this._ngZone=e,this.registry=i,this._pendingCount=0,this._isZoneStable=!0,this._didWork=!1,this._callbacks=[],this.taskTrackingZone=null,Ix||(function lde(t){Ix=t}(r),r.addToWindow(i)),this._watchAngularEvents(),e.run(()=>{this.taskTrackingZone=typeof Zone>"u"?null:Zone.current.get("TaskTrackingZone")})}_watchAngularEvents(){this._ngZone.onUnstable.subscribe({next:()=>{this._didWork=!0,this._isZoneStable=!1}}),this._ngZone.runOutsideAngular(()=>{this._ngZone.onStable.subscribe({next:()=>{Xn.assertNotInAngularZone(),queueMicrotask(()=>{this._isZoneStable=!0,this._runCallbacksIfReady()})}})})}increasePendingRequestCount(){return this._pendingCount+=1,this._didWork=!0,this._pendingCount}decreasePendingRequestCount(){if(this._pendingCount-=1,this._pendingCount<0)throw new Error("pending async requests below zero");return this._runCallbacksIfReady(),this._pendingCount}isStable(){return this._isZoneStable&&0===this._pendingCount&&!this._ngZone.hasPendingMacrotasks}_runCallbacksIfReady(){if(this.isStable())queueMicrotask(()=>{for(;0!==this._callbacks.length;){let e=this._callbacks.pop();clearTimeout(e.timeoutId),e.doneCb(this._didWork)}this._didWork=!1});else{let e=this.getPendingTasks();this._callbacks=this._callbacks.filter(i=>!i.updateCb||!i.updateCb(e)||(clearTimeout(i.timeoutId),!1)),this._didWork=!0}}getPendingTasks(){return this.taskTrackingZone?this.taskTrackingZone.macroTasks.map(e=>({source:e.source,creationLocation:e.creationLocation,data:e.data})):[]}addCallback(e,i,r){let s=-1;i&&i>0&&(s=setTimeout(()=>{this._callbacks=this._callbacks.filter(a=>a.timeoutId!==s),e(this._didWork,this.getPendingTasks())},i)),this._callbacks.push({doneCb:e,timeoutId:s,updateCb:r})}whenStable(e,i,r){if(r&&!this.taskTrackingZone)throw new Error('Task tracking zone is required when passing an update callback to whenStable(). Is "zone.js/plugins/task-tracking" loaded?');this.addCallback(e,i,r),this._runCallbacksIfReady()}getPendingRequestCount(){return this._pendingCount}registerApplication(e){this.registry.registerApplication(e,this)}unregisterApplication(e){this.registry.unregisterApplication(e)}findProviders(e,i,r){return[]}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Xn),gt(Ax),gt(M9))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})(),Ax=(()=>{class t{constructor(){this._applications=new Map}registerApplication(e,i){this._applications.set(e,i)}unregisterApplication(e){this._applications.delete(e)}unregisterAllApplications(){this._applications.clear()}getTestability(e){return this._applications.get(e)||null}getAllTestabilities(){return Array.from(this._applications.values())}getAllRootElements(){return Array.from(this._applications.keys())}findTestabilityInTree(e,i=!0){return Ix?.findTestabilityInTree(this,e,i)??null}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"platform"})}return t})(),A3=null;const tV=new Jt("AllowMultipleToken"),Dx=new Jt("PlatformDestroyListeners"),Nx=new Jt("appBootstrapListener");class iV{constructor(n,e){this.name=n,this.token=e}}function sV(t,n,e=[]){const i=`Platform: ${n}`,r=new Jt(i);return(s=[])=>{let a=Rx();if(!a||a.injector.get(tV,!1)){const o=[...e,...s,{provide:r,useValue:!0}];t?t(o):function fde(t){if(A3&&!A3.get(tV,!1))throw new kt(400,!1);(function nV(){!function i6(t){sl=t}(()=>{throw new kt(600,!1)})})(),A3=t;const n=t.get(oV);(function rV(t){t.get(wP,null)?.forEach(e=>e())})(t)}(function aV(t=[],n){return ks.create({name:n,providers:[{provide:fC,useValue:"platform"},{provide:Dx,useValue:new Set([()=>A3=null])},...t]})}(o,i))}return function pde(t){const n=Rx();if(!n)throw new kt(401,!1);return n}()}}function Rx(){return A3?.get(oV)??null}let oV=(()=>{class t{constructor(e){this._injector=e,this._modules=[],this._destroyListeners=[],this._destroyed=!1}bootstrapModuleFactory(e,i){const r=function mde(t="zone.js",n){return"noop"===t?new l3e:"zone.js"===t?new Xn(n):t}(i?.ngZone,function cV(t){return{enableLongStackTrace:!1,shouldCoalesceEventChangeDetection:t?.eventCoalescing??!1,shouldCoalesceRunChangeDetection:t?.runCoalescing??!1}}({eventCoalescing:i?.ngZoneEventCoalescing,runCoalescing:i?.ngZoneRunCoalescing}));return r.run(()=>{const s=function Lue(t,n,e){return new cx(t,n,e)}(e.moduleType,this.injector,function hV(t){return[{provide:Xn,useFactory:t},{provide:Ef,multi:!0,useFactory:()=>{const n=Kt(vde,{optional:!0});return()=>n.initialize()}},{provide:fV,useFactory:gde},{provide:OP,useFactory:HP}]}(()=>r)),a=s.injector.get(fl,null);return r.runOutsideAngular(()=>{const o=r.onError.subscribe({next:c=>{a.handleError(c)}});s.onDestroy(()=>{k9(this._modules,s),o.unsubscribe()})}),function lV(t,n,e){try{const i=e();return $f(i)?i.catch(r=>{throw n.runOutsideAngular(()=>t.handleError(r)),r}):i}catch(i){throw n.runOutsideAngular(()=>t.handleError(i)),i}}(a,r,()=>{const o=s.injector.get(Mx);return o.runInitializers(),o.donePromise.then(()=>(function LO(t){wo(t,"Expected localeId to be defined"),"string"==typeof t&&(RO=t.toLowerCase().replace(/_/g,"-"))}(s.injector.get(Q1,$6)||$6),this._moduleDoBootstrap(s),s))})})}bootstrapModule(e,i=[]){const r=uV({},i);return function ude(t,n,e){const i=new lx(e);return Promise.resolve(i)}(0,0,e).then(s=>this.bootstrapModuleFactory(s,r))}_moduleDoBootstrap(e){const i=e.injector.get(P2);if(e._bootstrapComponents.length>0)e._bootstrapComponents.forEach(r=>i.bootstrap(r));else{if(!e.instance.ngDoBootstrap)throw new kt(-403,!1);e.instance.ngDoBootstrap(i)}this._modules.push(e)}onDestroy(e){this._destroyListeners.push(e)}get injector(){return this._injector}destroy(){if(this._destroyed)throw new kt(404,!1);this._modules.slice().forEach(i=>i.destroy()),this._destroyListeners.forEach(i=>i());const e=this._injector.get(Dx,null);e&&(e.forEach(i=>i()),e.clear()),this._destroyed=!0}get destroyed(){return this._destroyed}static#e=this.\u0275fac=function(i){return new(i||t)(gt(ks))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"platform"})}return t})();function uV(t,n){return Array.isArray(n)?n.reduce(uV,t):{...t,...n}}let P2=(()=>{class t{constructor(){this._bootstrapListeners=[],this._runningTick=!1,this._destroyed=!1,this._destroyListeners=[],this._views=[],this.internalErrorHandler=Kt(fV),this.zoneIsStable=Kt(OP),this.componentTypes=[],this.components=[],this.isStable=Kt(YH).hasPendingTasks.pipe(vi(e=>e?ln(!1):this.zoneIsStable),r1(),H1()),this._injector=Kt(Ao)}get destroyed(){return this._destroyed}get injector(){return this._injector}bootstrap(e,i){const r=e instanceof kP;if(!this._injector.get(Mx).done)throw!r&&function ua(t){const n=Si(t)||is(t)||la(t);return null!==n&&n.standalone}(e),new kt(405,!1);let a;a=r?e:this._injector.get(Nf).resolveComponentFactory(e),this.componentTypes.push(a.componentType);const o=function dde(t){return t.isBoundToModule}(a)?void 0:this._injector.get(g4),l=a.create(ks.NULL,[],i||a.selector,o),u=l.location.nativeElement,d=l.injector.get(eV,null);return d?.registerApplication(u),l.onDestroy(()=>{this.detachView(l.hostView),k9(this.components,l),d?.unregisterApplication(u)}),this._loadComponent(l),l}tick(){if(this._runningTick)throw new kt(101,!1);try{this._runningTick=!0;for(let e of this._views)e.detectChanges()}catch(e){this.internalErrorHandler(e)}finally{this._runningTick=!1}}attachView(e){const i=e;this._views.push(i),i.attachToAppRef(this)}detachView(e){const i=e;k9(this._views,i),i.detachFromAppRef()}_loadComponent(e){this.attachView(e.hostView),this.tick(),this.components.push(e);const i=this._injector.get(Nx,[]);i.push(...this._bootstrapListeners),i.forEach(r=>r(e))}ngOnDestroy(){if(!this._destroyed)try{this._destroyListeners.forEach(e=>e()),this._views.slice().forEach(e=>e.destroy())}finally{this._destroyed=!0,this._views=[],this._bootstrapListeners=[],this._destroyListeners=[]}}onDestroy(e){return this._destroyListeners.push(e),()=>k9(this._destroyListeners,e)}destroy(){if(this._destroyed)throw new kt(406,!1);const e=this._injector;e.destroy&&!e.destroyed&&e.destroy()}get viewCount(){return this._views.length}warnIfDestroyed(){}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();function k9(t,n){const e=t.indexOf(n);e>-1&&t.splice(e,1)}const fV=new Jt("",{providedIn:"root",factory:()=>Kt(fl).handleError.bind(void 0)});function gde(){const t=Kt(Xn),n=Kt(fl);return e=>t.runOutsideAngular(()=>n.handleError(e))}let vde=(()=>{class t{constructor(){this.zone=Kt(Xn),this.applicationRef=Kt(P2)}initialize(){this._onMicrotaskEmptySubscription||(this._onMicrotaskEmptySubscription=this.zone.onMicrotaskEmpty.subscribe({next:()=>{this.zone.run(()=>{this.applicationRef.tick()})}}))}ngOnDestroy(){this._onMicrotaskEmptySubscription?.unsubscribe()}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();let Dr=(()=>{class t{static#e=this.__NG_ELEMENT_ID__=_de}return t})();function _de(t){return function bde(t,n,e){if(p3(t)&&!e){const i=Ks(t.index,n);return new zf(i,i)}return 47&t.type?new zf(n[Lr],n):null}(zs(),Ot(),16==(16&t))}class vV{constructor(){}supports(n){return u9(n)}create(n){return new kde(n)}}const Mde=(t,n)=>n;class kde{constructor(n){this.length=0,this._linkedRecords=null,this._unlinkedRecords=null,this._previousItHead=null,this._itHead=null,this._itTail=null,this._additionsHead=null,this._additionsTail=null,this._movesHead=null,this._movesTail=null,this._removalsHead=null,this._removalsTail=null,this._identityChangesHead=null,this._identityChangesTail=null,this._trackByFn=n||Mde}forEachItem(n){let e;for(e=this._itHead;null!==e;e=e._next)n(e)}forEachOperation(n){let e=this._itHead,i=this._removalsHead,r=0,s=null;for(;e||i;){const a=!i||e&&e.currentIndex<_V(i,r,s)?e:i,o=_V(a,r,s),c=a.currentIndex;if(a===i)r--,i=i._nextRemoved;else if(e=e._next,null==a.previousIndex)r++;else{s||(s=[]);const l=o-r,u=c-r;if(l!=u){for(let h=0;h<l;h++){const y=h<s.length?s[h]:s[h]=0,I=y+h;u<=I&&I<l&&(s[h]=y+1)}s[a.previousIndex]=u-l}}o!==c&&n(a,o,c)}}forEachPreviousItem(n){let e;for(e=this._previousItHead;null!==e;e=e._nextPrevious)n(e)}forEachAddedItem(n){let e;for(e=this._additionsHead;null!==e;e=e._nextAdded)n(e)}forEachMovedItem(n){let e;for(e=this._movesHead;null!==e;e=e._nextMoved)n(e)}forEachRemovedItem(n){let e;for(e=this._removalsHead;null!==e;e=e._nextRemoved)n(e)}forEachIdentityChange(n){let e;for(e=this._identityChangesHead;null!==e;e=e._nextIdentityChange)n(e)}diff(n){if(null==n&&(n=[]),!u9(n))throw new kt(900,!1);return this.check(n)?this:null}onDestroy(){}check(n){this._reset();let r,s,a,e=this._itHead,i=!1;if(Array.isArray(n)){this.length=n.length;for(let o=0;o<this.length;o++)s=n[o],a=this._trackByFn(o,s),null!==e&&Object.is(e.trackById,a)?(i&&(e=this._verifyReinsertion(e,s,a,o)),Object.is(e.item,s)||this._addIdentityChange(e,s)):(e=this._mismatch(e,s,a,o),i=!0),e=e._next}else r=0,function g0e(t,n){if(Array.isArray(t))for(let e=0;e<t.length;e++)n(t[e]);else{const e=t[Symbol.iterator]();let i;for(;!(i=e.next()).done;)n(i.value)}}(n,o=>{a=this._trackByFn(r,o),null!==e&&Object.is(e.trackById,a)?(i&&(e=this._verifyReinsertion(e,o,a,r)),Object.is(e.item,o)||this._addIdentityChange(e,o)):(e=this._mismatch(e,o,a,r),i=!0),e=e._next,r++}),this.length=r;return this._truncate(e),this.collection=n,this.isDirty}get isDirty(){return null!==this._additionsHead||null!==this._movesHead||null!==this._removalsHead||null!==this._identityChangesHead}_reset(){if(this.isDirty){let n;for(n=this._previousItHead=this._itHead;null!==n;n=n._next)n._nextPrevious=n._next;for(n=this._additionsHead;null!==n;n=n._nextAdded)n.previousIndex=n.currentIndex;for(this._additionsHead=this._additionsTail=null,n=this._movesHead;null!==n;n=n._nextMoved)n.previousIndex=n.currentIndex;this._movesHead=this._movesTail=null,this._removalsHead=this._removalsTail=null,this._identityChangesHead=this._identityChangesTail=null}}_mismatch(n,e,i,r){let s;return null===n?s=this._itTail:(s=n._prev,this._remove(n)),null!==(n=null===this._unlinkedRecords?null:this._unlinkedRecords.get(i,null))?(Object.is(n.item,e)||this._addIdentityChange(n,e),this._reinsertAfter(n,s,r)):null!==(n=null===this._linkedRecords?null:this._linkedRecords.get(i,r))?(Object.is(n.item,e)||this._addIdentityChange(n,e),this._moveAfter(n,s,r)):n=this._addAfter(new Sde(e,i),s,r),n}_verifyReinsertion(n,e,i,r){let s=null===this._unlinkedRecords?null:this._unlinkedRecords.get(i,null);return null!==s?n=this._reinsertAfter(s,n._prev,r):n.currentIndex!=r&&(n.currentIndex=r,this._addToMoves(n,r)),n}_truncate(n){for(;null!==n;){const e=n._next;this._addToRemovals(this._unlink(n)),n=e}null!==this._unlinkedRecords&&this._unlinkedRecords.clear(),null!==this._additionsTail&&(this._additionsTail._nextAdded=null),null!==this._movesTail&&(this._movesTail._nextMoved=null),null!==this._itTail&&(this._itTail._next=null),null!==this._removalsTail&&(this._removalsTail._nextRemoved=null),null!==this._identityChangesTail&&(this._identityChangesTail._nextIdentityChange=null)}_reinsertAfter(n,e,i){null!==this._unlinkedRecords&&this._unlinkedRecords.remove(n);const r=n._prevRemoved,s=n._nextRemoved;return null===r?this._removalsHead=s:r._nextRemoved=s,null===s?this._removalsTail=r:s._prevRemoved=r,this._insertAfter(n,e,i),this._addToMoves(n,i),n}_moveAfter(n,e,i){return this._unlink(n),this._insertAfter(n,e,i),this._addToMoves(n,i),n}_addAfter(n,e,i){return this._insertAfter(n,e,i),this._additionsTail=null===this._additionsTail?this._additionsHead=n:this._additionsTail._nextAdded=n,n}_insertAfter(n,e,i){const r=null===e?this._itHead:e._next;return n._next=r,n._prev=e,null===r?this._itTail=n:r._prev=n,null===e?this._itHead=n:e._next=n,null===this._linkedRecords&&(this._linkedRecords=new yV),this._linkedRecords.put(n),n.currentIndex=i,n}_remove(n){return this._addToRemovals(this._unlink(n))}_unlink(n){null!==this._linkedRecords&&this._linkedRecords.remove(n);const e=n._prev,i=n._next;return null===e?this._itHead=i:e._next=i,null===i?this._itTail=e:i._prev=e,n}_addToMoves(n,e){return n.previousIndex===e||(this._movesTail=null===this._movesTail?this._movesHead=n:this._movesTail._nextMoved=n),n}_addToRemovals(n){return null===this._unlinkedRecords&&(this._unlinkedRecords=new yV),this._unlinkedRecords.put(n),n.currentIndex=null,n._nextRemoved=null,null===this._removalsTail?(this._removalsTail=this._removalsHead=n,n._prevRemoved=null):(n._prevRemoved=this._removalsTail,this._removalsTail=this._removalsTail._nextRemoved=n),n}_addIdentityChange(n,e){return n.item=e,this._identityChangesTail=null===this._identityChangesTail?this._identityChangesHead=n:this._identityChangesTail._nextIdentityChange=n,n}}class Sde{constructor(n,e){this.item=n,this.trackById=e,this.currentIndex=null,this.previousIndex=null,this._nextPrevious=null,this._prev=null,this._next=null,this._prevDup=null,this._nextDup=null,this._prevRemoved=null,this._nextRemoved=null,this._nextAdded=null,this._nextMoved=null,this._nextIdentityChange=null}}class Ede{constructor(){this._head=null,this._tail=null}add(n){null===this._head?(this._head=this._tail=n,n._nextDup=null,n._prevDup=null):(this._tail._nextDup=n,n._prevDup=this._tail,n._nextDup=null,this._tail=n)}get(n,e){let i;for(i=this._head;null!==i;i=i._nextDup)if((null===e||e<=i.currentIndex)&&Object.is(i.trackById,n))return i;return null}remove(n){const e=n._prevDup,i=n._nextDup;return null===e?this._head=i:e._nextDup=i,null===i?this._tail=e:i._prevDup=e,null===this._head}}class yV{constructor(){this.map=new Map}put(n){const e=n.trackById;let i=this.map.get(e);i||(i=new Ede,this.map.set(e,i)),i.add(n)}get(n,e){const r=this.map.get(n);return r?r.get(n,e):null}remove(n){const e=n.trackById;return this.map.get(e).remove(n)&&this.map.delete(e),n}get isEmpty(){return 0===this.map.size}clear(){this.map.clear()}}function _V(t,n,e){const i=t.previousIndex;if(null===i)return i;let r=0;return e&&i<e.length&&(r=e[i]),i+n+r}class bV{constructor(){}supports(n){return n instanceof Map||jC(n)}create(){return new Ade}}class Ade{constructor(){this._records=new Map,this._mapHead=null,this._appendAfter=null,this._previousMapHead=null,this._changesHead=null,this._changesTail=null,this._additionsHead=null,this._additionsTail=null,this._removalsHead=null,this._removalsTail=null}get isDirty(){return null!==this._additionsHead||null!==this._changesHead||null!==this._removalsHead}forEachItem(n){let e;for(e=this._mapHead;null!==e;e=e._next)n(e)}forEachPreviousItem(n){let e;for(e=this._previousMapHead;null!==e;e=e._nextPrevious)n(e)}forEachChangedItem(n){let e;for(e=this._changesHead;null!==e;e=e._nextChanged)n(e)}forEachAddedItem(n){let e;for(e=this._additionsHead;null!==e;e=e._nextAdded)n(e)}forEachRemovedItem(n){let e;for(e=this._removalsHead;null!==e;e=e._nextRemoved)n(e)}diff(n){if(n){if(!(n instanceof Map||jC(n)))throw new kt(900,!1)}else n=new Map;return this.check(n)?this:null}onDestroy(){}check(n){this._reset();let e=this._mapHead;if(this._appendAfter=null,this._forEach(n,(i,r)=>{if(e&&e.key===r)this._maybeAddToChanges(e,i),this._appendAfter=e,e=e._next;else{const s=this._getOrCreateRecordForKey(r,i);e=this._insertBeforeOrAppend(e,s)}}),e){e._prev&&(e._prev._next=null),this._removalsHead=e;for(let i=e;null!==i;i=i._nextRemoved)i===this._mapHead&&(this._mapHead=null),this._records.delete(i.key),i._nextRemoved=i._next,i.previousValue=i.currentValue,i.currentValue=null,i._prev=null,i._next=null}return this._changesTail&&(this._changesTail._nextChanged=null),this._additionsTail&&(this._additionsTail._nextAdded=null),this.isDirty}_insertBeforeOrAppend(n,e){if(n){const i=n._prev;return e._next=n,e._prev=i,n._prev=e,i&&(i._next=e),n===this._mapHead&&(this._mapHead=e),this._appendAfter=n,n}return this._appendAfter?(this._appendAfter._next=e,e._prev=this._appendAfter):this._mapHead=e,this._appendAfter=e,null}_getOrCreateRecordForKey(n,e){if(this._records.has(n)){const r=this._records.get(n);this._maybeAddToChanges(r,e);const s=r._prev,a=r._next;return s&&(s._next=a),a&&(a._prev=s),r._next=null,r._prev=null,r}const i=new Ide(n);return this._records.set(n,i),i.currentValue=e,this._addToAdditions(i),i}_reset(){if(this.isDirty){let n;for(this._previousMapHead=this._mapHead,n=this._previousMapHead;null!==n;n=n._next)n._nextPrevious=n._next;for(n=this._changesHead;null!==n;n=n._nextChanged)n.previousValue=n.currentValue;for(n=this._additionsHead;null!=n;n=n._nextAdded)n.previousValue=n.currentValue;this._changesHead=this._changesTail=null,this._additionsHead=this._additionsTail=null,this._removalsHead=null}}_maybeAddToChanges(n,e){Object.is(e,n.currentValue)||(n.previousValue=n.currentValue,n.currentValue=e,this._addToChanges(n))}_addToAdditions(n){null===this._additionsHead?this._additionsHead=this._additionsTail=n:(this._additionsTail._nextAdded=n,this._additionsTail=n)}_addToChanges(n){null===this._changesHead?this._changesHead=this._changesTail=n:(this._changesTail._nextChanged=n,this._changesTail=n)}_forEach(n,e){n instanceof Map?n.forEach(e):Object.keys(n).forEach(i=>e(n[i],i))}}class Ide{constructor(n){this.key=n,this.previousValue=null,this.currentValue=null,this._nextPrevious=null,this._next=null,this._prev=null,this._nextAdded=null,this._nextRemoved=null,this._nextChanged=null}}function wV(){return new gl([new vV])}let gl=(()=>{class t{static#e=this.\u0275prov=Pt({token:t,providedIn:"root",factory:wV});constructor(e){this.factories=e}static create(e,i){if(null!=i){const r=i.factories.slice();e=e.concat(r)}return new t(e)}static extend(e){return{provide:t,useFactory:i=>t.create(e,i||wV()),deps:[[t,new bf,new _f]]}}find(e){const i=this.factories.find(r=>r.supports(e));if(null!=i)return i;throw new kt(901,!1)}}return t})();function CV(){return new n8([new bV])}let n8=(()=>{class t{static#e=this.\u0275prov=Pt({token:t,providedIn:"root",factory:CV});constructor(e){this.factories=e}static create(e,i){if(i){const r=i.factories.slice();e=e.concat(r)}return new t(e)}static extend(e){return{provide:t,useFactory:i=>t.create(e,i||CV()),deps:[[t,new bf,new _f]]}}find(e){const i=this.factories.find(r=>r.supports(e));if(i)return i;throw new kt(901,!1)}}return t})();const Rde=sV(null,"core",[]);let Lde=(()=>{class t{constructor(e){}static#e=this.\u0275fac=function(i){return new(i||t)(gt(P2))};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();function q6(t){return"boolean"==typeof t?t:null!=t&&"false"!==t}function Vx(t,n){const e=Si(t),i=n.elementInjector||Km();return new Of(e).create(i,n.projectableNodes,n.hostElement,n.environmentInjector)}let Fx=null;function I3(){return Fx}class Zde{}const Pi=new Jt("DocumentToken");let Bx=(()=>{class t{historyGo(e){throw new Error("Not implemented")}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return Kt(Kde)},providedIn:"platform"})}return t})();const Yde=new Jt("Location Initialized");let Kde=(()=>{class t extends Bx{constructor(){super(),this._doc=Kt(Pi),this._location=window.location,this._history=window.history}getBaseHrefFromDOM(){return I3().getBaseHref(this._doc)}onPopState(e){const i=I3().getGlobalEventTarget(this._doc,"window");return i.addEventListener("popstate",e,!1),()=>i.removeEventListener("popstate",e)}onHashChange(e){const i=I3().getGlobalEventTarget(this._doc,"window");return i.addEventListener("hashchange",e,!1),()=>i.removeEventListener("hashchange",e)}get href(){return this._location.href}get protocol(){return this._location.protocol}get hostname(){return this._location.hostname}get port(){return this._location.port}get pathname(){return this._location.pathname}get search(){return this._location.search}get hash(){return this._location.hash}set pathname(e){this._location.pathname=e}pushState(e,i,r){this._history.pushState(e,i,r)}replaceState(e,i,r){this._history.replaceState(e,i,r)}forward(){this._history.forward()}back(){this._history.back()}historyGo(e=0){this._history.go(e)}getState(){return this._history.state}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return new t},providedIn:"platform"})}return t})();function Ux(t,n){if(0==t.length)return n;if(0==n.length)return t;let e=0;return t.endsWith("/")&&e++,n.startsWith("/")&&e++,2==e?t+n.substring(1):1==e?t+n:t+"/"+n}function DV(t){const n=t.match(/#|\?|$/),e=n&&n.index||t.length;return t.slice(0,e-("/"===t[e-1]?1:0))+t.slice(e)}function vl(t){return t&&"?"!==t[0]?"?"+t:t}let y4=(()=>{class t{historyGo(e){throw new Error("Not implemented")}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return Kt(RV)},providedIn:"root"})}return t})();const NV=new Jt("appBaseHref");let RV=(()=>{class t extends y4{constructor(e,i){super(),this._platformLocation=e,this._removeListenerFns=[],this._baseHref=i??this._platformLocation.getBaseHrefFromDOM()??Kt(Pi).location?.origin??""}ngOnDestroy(){for(;this._removeListenerFns.length;)this._removeListenerFns.pop()()}onPopState(e){this._removeListenerFns.push(this._platformLocation.onPopState(e),this._platformLocation.onHashChange(e))}getBaseHref(){return this._baseHref}prepareExternalUrl(e){return Ux(this._baseHref,e)}path(e=!1){const i=this._platformLocation.pathname+vl(this._platformLocation.search),r=this._platformLocation.hash;return r&&e?`${i}${r}`:i}pushState(e,i,r,s){const a=this.prepareExternalUrl(r+vl(s));this._platformLocation.pushState(e,i,a)}replaceState(e,i,r,s){const a=this.prepareExternalUrl(r+vl(s));this._platformLocation.replaceState(e,i,a)}forward(){this._platformLocation.forward()}back(){this._platformLocation.back()}getState(){return this._platformLocation.getState()}historyGo(e=0){this._platformLocation.historyGo?.(e)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Bx),gt(NV,8))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),Xde=(()=>{class t extends y4{constructor(e,i){super(),this._platformLocation=e,this._baseHref="",this._removeListenerFns=[],null!=i&&(this._baseHref=i)}ngOnDestroy(){for(;this._removeListenerFns.length;)this._removeListenerFns.pop()()}onPopState(e){this._removeListenerFns.push(this._platformLocation.onPopState(e),this._platformLocation.onHashChange(e))}getBaseHref(){return this._baseHref}path(e=!1){let i=this._platformLocation.hash;return null==i&&(i="#"),i.length>0?i.substring(1):i}prepareExternalUrl(e){const i=Ux(this._baseHref,e);return i.length>0?"#"+i:i}pushState(e,i,r,s){let a=this.prepareExternalUrl(r+vl(s));0==a.length&&(a=this._platformLocation.pathname),this._platformLocation.pushState(e,i,a)}replaceState(e,i,r,s){let a=this.prepareExternalUrl(r+vl(s));0==a.length&&(a=this._platformLocation.pathname),this._platformLocation.replaceState(e,i,a)}forward(){this._platformLocation.forward()}back(){this._platformLocation.back()}getState(){return this._platformLocation.getState()}historyGo(e=0){this._platformLocation.historyGo?.(e)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Bx),gt(NV,8))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})(),$x=(()=>{class t{constructor(e){this._subject=new Ht,this._urlChangeListeners=[],this._urlChangeSubscription=null,this._locationStrategy=e;const i=this._locationStrategy.getBaseHref();this._basePath=function e5e(t){if(new RegExp("^(https?:)?//").test(t)){const[,e]=t.split(/\/\/[^\/]+/);return e}return t}(DV(LV(i))),this._locationStrategy.onPopState(r=>{this._subject.emit({url:this.path(!0),pop:!0,state:r.state,type:r.type})})}ngOnDestroy(){this._urlChangeSubscription?.unsubscribe(),this._urlChangeListeners=[]}path(e=!1){return this.normalize(this._locationStrategy.path(e))}getState(){return this._locationStrategy.getState()}isCurrentPathEqualTo(e,i=""){return this.path()==this.normalize(e+vl(i))}normalize(e){return t.stripTrailingSlash(function Jde(t,n){if(!t||!n.startsWith(t))return n;const e=n.substring(t.length);return""===e||["/",";","?","#"].includes(e[0])?e:n}(this._basePath,LV(e)))}prepareExternalUrl(e){return e&&"/"!==e[0]&&(e="/"+e),this._locationStrategy.prepareExternalUrl(e)}go(e,i="",r=null){this._locationStrategy.pushState(r,"",e,i),this._notifyUrlChangeListeners(this.prepareExternalUrl(e+vl(i)),r)}replaceState(e,i="",r=null){this._locationStrategy.replaceState(r,"",e,i),this._notifyUrlChangeListeners(this.prepareExternalUrl(e+vl(i)),r)}forward(){this._locationStrategy.forward()}back(){this._locationStrategy.back()}historyGo(e=0){this._locationStrategy.historyGo?.(e)}onUrlChange(e){return this._urlChangeListeners.push(e),this._urlChangeSubscription||(this._urlChangeSubscription=this.subscribe(i=>{this._notifyUrlChangeListeners(i.url,i.state)})),()=>{const i=this._urlChangeListeners.indexOf(e);this._urlChangeListeners.splice(i,1),0===this._urlChangeListeners.length&&(this._urlChangeSubscription?.unsubscribe(),this._urlChangeSubscription=null)}}_notifyUrlChangeListeners(e="",i){this._urlChangeListeners.forEach(r=>r(e,i))}subscribe(e,i,r){return this._subject.subscribe({next:e,error:i,complete:r})}static#e=this.normalizeQueryParams=vl;static#t=this.joinWithSlash=Ux;static#n=this.stripTrailingSlash=DV;static#i=this.\u0275fac=function(i){return new(i||t)(gt(y4))};static#r=this.\u0275prov=Pt({token:t,factory:function(){return function Qde(){return new $x(gt(y4))}()},providedIn:"root"})}return t})();function LV(t){return t.replace(/\/index.html$/,"")}var I9=function(t){return t[t.Decimal=0]="Decimal",t[t.Percent=1]="Percent",t[t.Currency=2]="Currency",t[t.Scientific=3]="Scientific",t}(I9||{}),Js=function(t){return t[t.Format=0]="Format",t[t.Standalone=1]="Standalone",t}(Js||{}),qi=function(t){return t[t.Narrow=0]="Narrow",t[t.Abbreviated=1]="Abbreviated",t[t.Wide=2]="Wide",t[t.Short=3]="Short",t}(qi||{}),b1=function(t){return t[t.Short=0]="Short",t[t.Medium=1]="Medium",t[t.Long=2]="Long",t[t.Full=3]="Full",t}(b1||{}),_s=function(t){return t[t.Decimal=0]="Decimal",t[t.Group=1]="Group",t[t.List=2]="List",t[t.PercentSign=3]="PercentSign",t[t.PlusSign=4]="PlusSign",t[t.MinusSign=5]="MinusSign",t[t.Exponential=6]="Exponential",t[t.SuperscriptingExponent=7]="SuperscriptingExponent",t[t.PerMille=8]="PerMille",t[t.Infinity=9]="Infinity",t[t.NaN=10]="NaN",t[t.TimeSeparator=11]="TimeSeparator",t[t.CurrencyDecimal=12]="CurrencyDecimal",t[t.CurrencyGroup=13]="CurrencyGroup",t}(_s||{});function D9(t,n){return e2(ro(t)[zr.DateFormat],n)}function N9(t,n){return e2(ro(t)[zr.TimeFormat],n)}function R9(t,n){return e2(ro(t)[zr.DateTimeFormat],n)}function J1(t,n){const e=ro(t),i=e[zr.NumberSymbols][n];if(typeof i>"u"){if(n===_s.CurrencyDecimal)return e[zr.NumberSymbols][_s.Decimal];if(n===_s.CurrencyGroup)return e[zr.NumberSymbols][_s.Group]}return i}function OV(t){if(!t[zr.ExtraData])throw new Error(`Missing extra locale data for the locale "${t[zr.LocaleId]}". Use "registerLocaleData" to load new data. See the "I18n guide" on angular.io to know more.`)}function e2(t,n){for(let e=n;e>-1;e--)if(typeof t[e]<"u")return t[e];throw new Error("Locale data API: locale data undefined")}function qx(t){const[n,e]=t.split(":");return{hours:+n,minutes:+e}}const f5e=/^(\d{4,})-?(\d\d)-?(\d\d)(?:T(\d\d)(?::?(\d\d)(?::?(\d\d)(?:\.(\d+))?)?)?(Z|([+-])(\d\d):?(\d\d))?)?$/,i8={},h5e=/((?:[^BEGHLMOSWYZabcdhmswyz']+)|(?:'(?:[^']|'')*')|(?:G{1,5}|y{1,4}|Y{1,4}|M{1,5}|L{1,5}|w{1,2}|W{1}|d{1,2}|E{1,6}|c{1,6}|a{1,5}|b{1,5}|B{1,5}|h{1,2}|H{1,2}|m{1,2}|s{1,2}|S{1,3}|z{1,4}|Z{1,5}|O{1,4}))([\s\S]*)/;var yl=function(t){return t[t.Short=0]="Short",t[t.ShortGMT=1]="ShortGMT",t[t.Long=2]="Long",t[t.Extended=3]="Extended",t}(yl||{}),or=function(t){return t[t.FullYear=0]="FullYear",t[t.Month=1]="Month",t[t.Date=2]="Date",t[t.Hours=3]="Hours",t[t.Minutes=4]="Minutes",t[t.Seconds=5]="Seconds",t[t.FractionalSeconds=6]="FractionalSeconds",t[t.Day=7]="Day",t}(or||{}),cr=function(t){return t[t.DayPeriods=0]="DayPeriods",t[t.Days=1]="Days",t[t.Months=2]="Months",t[t.Eras=3]="Eras",t}(cr||{});function HV(t,n,e,i){let r=function C5e(t){if(BV(t))return t;if("number"==typeof t&&!isNaN(t))return new Date(t);if("string"==typeof t){if(t=t.trim(),/^(\d{4}(-\d{1,2}(-\d{1,2})?)?)$/.test(t)){const[r,s=1,a=1]=t.split("-").map(o=>+o);return L9(r,s-1,a)}const e=parseFloat(t);if(!isNaN(t-e))return new Date(e);let i;if(i=t.match(f5e))return function x5e(t){const n=new Date(0);let e=0,i=0;const r=t[8]?n.setUTCFullYear:n.setFullYear,s=t[8]?n.setUTCHours:n.setHours;t[9]&&(e=Number(t[9]+t[10]),i=Number(t[9]+t[11])),r.call(n,Number(t[1]),Number(t[2])-1,Number(t[3]));const a=Number(t[4]||0)-e,o=Number(t[5]||0)-i,c=Number(t[6]||0),l=Math.floor(1e3*parseFloat("0."+(t[7]||0)));return s.call(n,a,o,c,l),n}(i)}const n=new Date(t);if(!BV(n))throw new Error(`Unable to convert "${t}" into a date`);return n}(t);n=_l(e,n)||n;let o,a=[];for(;n;){if(o=h5e.exec(n),!o){a.push(n);break}{a=a.concat(o.slice(1));const u=a.pop();if(!u)break;n=u}}let c=r.getTimezoneOffset();i&&(c=FV(i,c),r=function w5e(t,n,e){const i=e?-1:1,r=t.getTimezoneOffset();return function b5e(t,n){return(t=new Date(t.getTime())).setMinutes(t.getMinutes()+n),t}(t,i*(FV(n,r)-r))}(r,i,!0));let l="";return a.forEach(u=>{const d=function _5e(t){if(Zx[t])return Zx[t];let n;switch(t){case"G":case"GG":case"GGG":n=Or(cr.Eras,qi.Abbreviated);break;case"GGGG":n=Or(cr.Eras,qi.Wide);break;case"GGGGG":n=Or(cr.Eras,qi.Narrow);break;case"y":n=Ss(or.FullYear,1,0,!1,!0);break;case"yy":n=Ss(or.FullYear,2,0,!0,!0);break;case"yyy":n=Ss(or.FullYear,3,0,!1,!0);break;case"yyyy":n=Ss(or.FullYear,4,0,!1,!0);break;case"Y":n=H9(1);break;case"YY":n=H9(2,!0);break;case"YYY":n=H9(3);break;case"YYYY":n=H9(4);break;case"M":case"L":n=Ss(or.Month,1,1);break;case"MM":case"LL":n=Ss(or.Month,2,1);break;case"MMM":n=Or(cr.Months,qi.Abbreviated);break;case"MMMM":n=Or(cr.Months,qi.Wide);break;case"MMMMM":n=Or(cr.Months,qi.Narrow);break;case"LLL":n=Or(cr.Months,qi.Abbreviated,Js.Standalone);break;case"LLLL":n=Or(cr.Months,qi.Wide,Js.Standalone);break;case"LLLLL":n=Or(cr.Months,qi.Narrow,Js.Standalone);break;case"w":n=Gx(1);break;case"ww":n=Gx(2);break;case"W":n=Gx(1,!0);break;case"d":n=Ss(or.Date,1);break;case"dd":n=Ss(or.Date,2);break;case"c":case"cc":n=Ss(or.Day,1);break;case"ccc":n=Or(cr.Days,qi.Abbreviated,Js.Standalone);break;case"cccc":n=Or(cr.Days,qi.Wide,Js.Standalone);break;case"ccccc":n=Or(cr.Days,qi.Narrow,Js.Standalone);break;case"cccccc":n=Or(cr.Days,qi.Short,Js.Standalone);break;case"E":case"EE":case"EEE":n=Or(cr.Days,qi.Abbreviated);break;case"EEEE":n=Or(cr.Days,qi.Wide);break;case"EEEEE":n=Or(cr.Days,qi.Narrow);break;case"EEEEEE":n=Or(cr.Days,qi.Short);break;case"a":case"aa":case"aaa":n=Or(cr.DayPeriods,qi.Abbreviated);break;case"aaaa":n=Or(cr.DayPeriods,qi.Wide);break;case"aaaaa":n=Or(cr.DayPeriods,qi.Narrow);break;case"b":case"bb":case"bbb":n=Or(cr.DayPeriods,qi.Abbreviated,Js.Standalone,!0);break;case"bbbb":n=Or(cr.DayPeriods,qi.Wide,Js.Standalone,!0);break;case"bbbbb":n=Or(cr.DayPeriods,qi.Narrow,Js.Standalone,!0);break;case"B":case"BB":case"BBB":n=Or(cr.DayPeriods,qi.Abbreviated,Js.Format,!0);break;case"BBBB":n=Or(cr.DayPeriods,qi.Wide,Js.Format,!0);break;case"BBBBB":n=Or(cr.DayPeriods,qi.Narrow,Js.Format,!0);break;case"h":n=Ss(or.Hours,1,-12);break;case"hh":n=Ss(or.Hours,2,-12);break;case"H":n=Ss(or.Hours,1);break;case"HH":n=Ss(or.Hours,2);break;case"m":n=Ss(or.Minutes,1);break;case"mm":n=Ss(or.Minutes,2);break;case"s":n=Ss(or.Seconds,1);break;case"ss":n=Ss(or.Seconds,2);break;case"S":n=Ss(or.FractionalSeconds,1);break;case"SS":n=Ss(or.FractionalSeconds,2);break;case"SSS":n=Ss(or.FractionalSeconds,3);break;case"Z":case"ZZ":case"ZZZ":n=z9(yl.Short);break;case"ZZZZZ":n=z9(yl.Extended);break;case"O":case"OO":case"OOO":case"z":case"zz":case"zzz":n=z9(yl.ShortGMT);break;case"OOOO":case"ZZZZ":case"zzzz":n=z9(yl.Long);break;default:return null}return Zx[t]=n,n}(u);l+=d?d(r,e,c):"''"===u?"'":u.replace(/(^'|'$)/g,"").replace(/''/g,"'")}),l}function L9(t,n,e){const i=new Date(0);return i.setFullYear(t,n,e),i.setHours(0,0,0),i}function _l(t,n){const e=function n5e(t){return ro(t)[zr.LocaleId]}(t);if(i8[e]=i8[e]||{},i8[e][n])return i8[e][n];let i="";switch(n){case"shortDate":i=D9(t,b1.Short);break;case"mediumDate":i=D9(t,b1.Medium);break;case"longDate":i=D9(t,b1.Long);break;case"fullDate":i=D9(t,b1.Full);break;case"shortTime":i=N9(t,b1.Short);break;case"mediumTime":i=N9(t,b1.Medium);break;case"longTime":i=N9(t,b1.Long);break;case"fullTime":i=N9(t,b1.Full);break;case"short":const r=_l(t,"shortTime"),s=_l(t,"shortDate");i=P9(R9(t,b1.Short),[r,s]);break;case"medium":const a=_l(t,"mediumTime"),o=_l(t,"mediumDate");i=P9(R9(t,b1.Medium),[a,o]);break;case"long":const c=_l(t,"longTime"),l=_l(t,"longDate");i=P9(R9(t,b1.Long),[c,l]);break;case"full":const u=_l(t,"fullTime"),d=_l(t,"fullDate");i=P9(R9(t,b1.Full),[u,d])}return i&&(i8[e][n]=i),i}function P9(t,n){return n&&(t=t.replace(/\{([^}]+)}/g,function(e,i){return null!=n&&i in n?n[i]:e})),t}function z2(t,n,e="-",i,r){let s="";(t<0||r&&t<=0)&&(r?t=1-t:(t=-t,s=e));let a=String(t);for(;a.length<n;)a="0"+a;return i&&(a=a.slice(a.length-n)),s+a}function Ss(t,n,e=0,i=!1,r=!1){return function(s,a){let o=function m5e(t,n){switch(t){case or.FullYear:return n.getFullYear();case or.Month:return n.getMonth();case or.Date:return n.getDate();case or.Hours:return n.getHours();case or.Minutes:return n.getMinutes();case or.Seconds:return n.getSeconds();case or.FractionalSeconds:return n.getMilliseconds();case or.Day:return n.getDay();default:throw new Error(`Unknown DateType value "${t}".`)}}(t,s);if((e>0||o>-e)&&(o+=e),t===or.Hours)0===o&&-12===e&&(o=12);else if(t===or.FractionalSeconds)return function p5e(t,n){return z2(t,3).substring(0,n)}(o,n);const c=J1(a,_s.MinusSign);return z2(o,n,c,i,r)}}function Or(t,n,e=Js.Format,i=!1){return function(r,s){return function g5e(t,n,e,i,r,s){switch(e){case cr.Months:return function jx(t,n,e){const i=ro(t),s=e2([i[zr.MonthsFormat],i[zr.MonthsStandalone]],n);return e2(s,e)}(n,r,i)[t.getMonth()];case cr.Days:return function zV(t,n,e){const i=ro(t),s=e2([i[zr.DaysFormat],i[zr.DaysStandalone]],n);return e2(s,e)}(n,r,i)[t.getDay()];case cr.DayPeriods:const a=t.getHours(),o=t.getMinutes();if(s){const l=function o5e(t){const n=ro(t);return OV(n),(n[zr.ExtraData][2]||[]).map(i=>"string"==typeof i?qx(i):[qx(i[0]),qx(i[1])])}(n),u=function c5e(t,n,e){const i=ro(t);OV(i);const s=e2([i[zr.ExtraData][0],i[zr.ExtraData][1]],n)||[];return e2(s,e)||[]}(n,r,i),d=l.findIndex(h=>{if(Array.isArray(h)){const[y,I]=h,D=a>=y.hours&&o>=y.minutes,V=a<I.hours||a===I.hours&&o<I.minutes;if(y.hours<I.hours){if(D&&V)return!0}else if(D||V)return!0}else if(h.hours===a&&h.minutes===o)return!0;return!1});if(-1!==d)return u[d]}return function i5e(t,n,e){const i=ro(t),s=e2([i[zr.DayPeriodsFormat],i[zr.DayPeriodsStandalone]],n);return e2(s,e)}(n,r,i)[a<12?0:1];case cr.Eras:return function r5e(t,n){return e2(ro(t)[zr.Eras],n)}(n,i)[t.getFullYear()<=0?0:1];default:throw new Error(`unexpected translation type ${e}`)}}(r,s,t,n,e,i)}}function z9(t){return function(n,e,i){const r=-1*i,s=J1(e,_s.MinusSign),a=r>0?Math.floor(r/60):Math.ceil(r/60);switch(t){case yl.Short:return(r>=0?"+":"")+z2(a,2,s)+z2(Math.abs(r%60),2,s);case yl.ShortGMT:return"GMT"+(r>=0?"+":"")+z2(a,1,s);case yl.Long:return"GMT"+(r>=0?"+":"")+z2(a,2,s)+":"+z2(Math.abs(r%60),2,s);case yl.Extended:return 0===i?"Z":(r>=0?"+":"")+z2(a,2,s)+":"+z2(Math.abs(r%60),2,s);default:throw new Error(`Unknown zone width "${t}"`)}}}const v5e=0,O9=4;function VV(t){return L9(t.getFullYear(),t.getMonth(),t.getDate()+(O9-t.getDay()))}function Gx(t,n=!1){return function(e,i){let r;if(n){const s=new Date(e.getFullYear(),e.getMonth(),1).getDay()-1,a=e.getDate();r=1+Math.floor((a+s)/7)}else{const s=VV(e),a=function y5e(t){const n=L9(t,v5e,1).getDay();return L9(t,0,1+(n<=O9?O9:O9+7)-n)}(s.getFullYear()),o=s.getTime()-a.getTime();r=1+Math.round(o/6048e5)}return z2(r,t,J1(i,_s.MinusSign))}}function H9(t,n=!1){return function(e,i){return z2(VV(e).getFullYear(),t,J1(i,_s.MinusSign),n)}}const Zx={};function FV(t,n){t=t.replace(/:/g,"");const e=Date.parse("Jan 01, 1970 00:00:00 "+t)/6e4;return isNaN(e)?n:e}function BV(t){return t instanceof Date&&!isNaN(t.valueOf())}const T5e=/^(\d+)?\.((\d+)(-(\d+))?)?$/;function Qx(t){const n=parseInt(t);if(isNaN(n))throw new Error("Invalid integer literal when parsing "+t);return n}const eT=/\s+/,WV=[];let Pn=(()=>{class t{constructor(e,i,r,s){this._iterableDiffers=e,this._keyValueDiffers=i,this._ngEl=r,this._renderer=s,this.initialClasses=WV,this.stateMap=new Map}set klass(e){this.initialClasses=null!=e?e.trim().split(eT):WV}set ngClass(e){this.rawClass="string"==typeof e?e.trim().split(eT):e}ngDoCheck(){for(const i of this.initialClasses)this._updateState(i,!0);const e=this.rawClass;if(Array.isArray(e)||e instanceof Set)for(const i of e)this._updateState(i,!0);else if(null!=e)for(const i of Object.keys(e))this._updateState(i,!!e[i]);this._applyStateDiff()}_updateState(e,i){const r=this.stateMap.get(e);void 0!==r?(r.enabled!==i&&(r.changed=!0,r.enabled=i),r.touched=!0):this.stateMap.set(e,{enabled:i,changed:!0,touched:!0})}_applyStateDiff(){for(const e of this.stateMap){const i=e[0],r=e[1];r.changed?(this._toggleClass(i,r.enabled),r.changed=!1):r.touched||(r.enabled&&this._toggleClass(i,!1),this.stateMap.delete(i)),r.touched=!1}}_toggleClass(e,i){(e=e.trim()).length>0&&e.split(eT).forEach(r=>{i?this._renderer.addClass(this._ngEl.nativeElement,r):this._renderer.removeClass(this._ngEl.nativeElement,r)})}static#e=this.\u0275fac=function(i){return new(i||t)(Te(gl),Te(n8),Te($n),Te(Io))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngClass",""]],inputs:{klass:["class","klass"],ngClass:"ngClass"},standalone:!0})}return t})(),F9=(()=>{class t{constructor(e){this._viewContainerRef=e,this.ngComponentOutlet=null,this._inputsUsed=new Map}_needToReCreateNgModuleInstance(e){return void 0!==e.ngComponentOutletNgModule||void 0!==e.ngComponentOutletNgModuleFactory}_needToReCreateComponentInstance(e){return void 0!==e.ngComponentOutlet||void 0!==e.ngComponentOutletContent||void 0!==e.ngComponentOutletInjector||this._needToReCreateNgModuleInstance(e)}ngOnChanges(e){if(this._needToReCreateComponentInstance(e)&&(this._viewContainerRef.clear(),this._inputsUsed.clear(),this._componentRef=void 0,this.ngComponentOutlet)){const i=this.ngComponentOutletInjector||this._viewContainerRef.parentInjector;this._needToReCreateNgModuleInstance(e)&&(this._moduleRef?.destroy(),this._moduleRef=this.ngComponentOutletNgModule?function Rue(t,n){return new cx(t,n??null,[])}(this.ngComponentOutletNgModule,qV(i)):this.ngComponentOutletNgModuleFactory?this.ngComponentOutletNgModuleFactory.create(qV(i)):void 0),this._componentRef=this._viewContainerRef.createComponent(this.ngComponentOutlet,{injector:i,ngModuleRef:this._moduleRef,projectableNodes:this.ngComponentOutletContent})}}ngDoCheck(){if(this._componentRef){if(this.ngComponentOutletInputs)for(const e of Object.keys(this.ngComponentOutletInputs))this._inputsUsed.set(e,!0);this._applyInputStateDiff(this._componentRef)}}ngOnDestroy(){this._moduleRef?.destroy()}_applyInputStateDiff(e){for(const[i,r]of this._inputsUsed)r?(e.setInput(i,this.ngComponentOutletInputs[i]),this._inputsUsed.set(i,!1)):(e.setInput(i,void 0),this._inputsUsed.delete(i))}static#e=this.\u0275fac=function(i){return new(i||t)(Te(ga))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngComponentOutlet",""]],inputs:{ngComponentOutlet:"ngComponentOutlet",ngComponentOutletInputs:"ngComponentOutletInputs",ngComponentOutletInjector:"ngComponentOutletInjector",ngComponentOutletContent:"ngComponentOutletContent",ngComponentOutletNgModule:"ngComponentOutletNgModule",ngComponentOutletNgModuleFactory:"ngComponentOutletNgModuleFactory"},standalone:!0,features:[Un]})}return t})();function qV(t){return t.get(g4).injector}class z5e{constructor(n,e,i,r){this.$implicit=n,this.ngForOf=e,this.index=i,this.count=r}get first(){return 0===this.index}get last(){return this.index===this.count-1}get even(){return this.index%2==0}get odd(){return!this.even}}let Fr=(()=>{class t{set ngForOf(e){this._ngForOf=e,this._ngForOfDirty=!0}set ngForTrackBy(e){this._trackByFn=e}get ngForTrackBy(){return this._trackByFn}constructor(e,i,r){this._viewContainer=e,this._template=i,this._differs=r,this._ngForOf=null,this._ngForOfDirty=!0,this._differ=null}set ngForTemplate(e){e&&(this._template=e)}ngDoCheck(){if(this._ngForOfDirty){this._ngForOfDirty=!1;const e=this._ngForOf;!this._differ&&e&&(this._differ=this._differs.find(e).create(this.ngForTrackBy))}if(this._differ){const e=this._differ.diff(this._ngForOf);e&&this._applyChanges(e)}}_applyChanges(e){const i=this._viewContainer;e.forEachOperation((r,s,a)=>{if(null==r.previousIndex)i.createEmbeddedView(this._template,new z5e(r.item,this._ngForOf,-1,-1),null===a?void 0:a);else if(null==a)i.remove(null===s?void 0:s);else if(null!==s){const o=i.get(s);i.move(o,a),GV(o,r)}});for(let r=0,s=i.length;r<s;r++){const o=i.get(r).context;o.index=r,o.count=s,o.ngForOf=this._ngForOf}e.forEachIdentityChange(r=>{GV(i.get(r.currentIndex),r)})}static ngTemplateContextGuard(e,i){return!0}static#e=this.\u0275fac=function(i){return new(i||t)(Te(ga),Te(sr),Te(gl))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngFor","","ngForOf",""]],inputs:{ngForOf:"ngForOf",ngForTrackBy:"ngForTrackBy",ngForTemplate:"ngForTemplate"},standalone:!0})}return t})();function GV(t,n){t.context.$implicit=n.item}let mn=(()=>{class t{constructor(e,i){this._viewContainer=e,this._context=new O5e,this._thenTemplateRef=null,this._elseTemplateRef=null,this._thenViewRef=null,this._elseViewRef=null,this._thenTemplateRef=i}set ngIf(e){this._context.$implicit=this._context.ngIf=e,this._updateView()}set ngIfThen(e){ZV("ngIfThen",e),this._thenTemplateRef=e,this._thenViewRef=null,this._updateView()}set ngIfElse(e){ZV("ngIfElse",e),this._elseTemplateRef=e,this._elseViewRef=null,this._updateView()}_updateView(){this._context.$implicit?this._thenViewRef||(this._viewContainer.clear(),this._elseViewRef=null,this._thenTemplateRef&&(this._thenViewRef=this._viewContainer.createEmbeddedView(this._thenTemplateRef,this._context))):this._elseViewRef||(this._viewContainer.clear(),this._thenViewRef=null,this._elseTemplateRef&&(this._elseViewRef=this._viewContainer.createEmbeddedView(this._elseTemplateRef,this._context)))}static ngTemplateContextGuard(e,i){return!0}static#e=this.\u0275fac=function(i){return new(i||t)(Te(ga),Te(sr))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngIf",""]],inputs:{ngIf:"ngIf",ngIfThen:"ngIfThen",ngIfElse:"ngIfElse"},standalone:!0})}return t})();class O5e{constructor(){this.$implicit=null,this.ngIf=null}}function ZV(t,n){if(n&&!n.createEmbeddedView)throw new Error(`${t} must be a TemplateRef, but received '${ni(n)}'.`)}class tT{constructor(n,e){this._viewContainerRef=n,this._templateRef=e,this._created=!1}create(){this._created=!0,this._viewContainerRef.createEmbeddedView(this._templateRef)}destroy(){this._created=!1,this._viewContainerRef.clear()}enforceState(n){n&&!this._created?this.create():!n&&this._created&&this.destroy()}}let B9=(()=>{class t{constructor(){this._defaultViews=[],this._defaultUsed=!1,this._caseCount=0,this._lastCaseCheckIndex=0,this._lastCasesMatched=!1}set ngSwitch(e){this._ngSwitch=e,0===this._caseCount&&this._updateDefaultCases(!0)}_addCase(){return this._caseCount++}_addDefault(e){this._defaultViews.push(e)}_matchCase(e){const i=e==this._ngSwitch;return this._lastCasesMatched=this._lastCasesMatched||i,this._lastCaseCheckIndex++,this._lastCaseCheckIndex===this._caseCount&&(this._updateDefaultCases(!this._lastCasesMatched),this._lastCaseCheckIndex=0,this._lastCasesMatched=!1),i}_updateDefaultCases(e){if(this._defaultViews.length>0&&e!==this._defaultUsed){this._defaultUsed=e;for(const i of this._defaultViews)i.enforceState(e)}}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngSwitch",""]],inputs:{ngSwitch:"ngSwitch"},standalone:!0})}return t})(),YV=(()=>{class t{constructor(e,i,r){this.ngSwitch=r,r._addCase(),this._view=new tT(e,i)}ngDoCheck(){this._view.enforceState(this.ngSwitch._matchCase(this.ngSwitchCase))}static#e=this.\u0275fac=function(i){return new(i||t)(Te(ga),Te(sr),Te(B9,9))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngSwitchCase",""]],inputs:{ngSwitchCase:"ngSwitchCase"},standalone:!0})}return t})(),yc=(()=>{class t{constructor(e){this._viewContainerRef=e,this._viewRef=null,this.ngTemplateOutletContext=null,this.ngTemplateOutlet=null,this.ngTemplateOutletInjector=null}ngOnChanges(e){if(e.ngTemplateOutlet||e.ngTemplateOutletInjector){const i=this._viewContainerRef;if(this._viewRef&&i.remove(i.indexOf(this._viewRef)),this.ngTemplateOutlet){const{ngTemplateOutlet:r,ngTemplateOutletContext:s,ngTemplateOutletInjector:a}=this;this._viewRef=i.createEmbeddedView(r,s,a?{injector:a}:void 0)}else this._viewRef=null}else this._viewRef&&e.ngTemplateOutletContext&&this.ngTemplateOutletContext&&(this._viewRef.context=this.ngTemplateOutletContext)}static#e=this.\u0275fac=function(i){return new(i||t)(Te(ga))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngTemplateOutlet",""]],inputs:{ngTemplateOutletContext:"ngTemplateOutletContext",ngTemplateOutlet:"ngTemplateOutlet",ngTemplateOutletInjector:"ngTemplateOutletInjector"},standalone:!0,features:[Un]})}return t})();function O2(t,n){return new kt(2100,!1)}const X5e=new Jt("DATE_PIPE_DEFAULT_TIMEZONE"),Q5e=new Jt("DATE_PIPE_DEFAULT_OPTIONS");let Z6=(()=>{class t{constructor(e,i,r){this.locale=e,this.defaultTimezone=i,this.defaultOptions=r}transform(e,i,r,s){if(null==e||""===e||e!=e)return null;try{return HV(e,i??this.defaultOptions?.dateFormat??"mediumDate",s||this.locale,r??this.defaultOptions?.timezone??this.defaultTimezone??void 0)}catch(a){throw O2()}}static#e=this.\u0275fac=function(i){return new(i||t)(Te(Q1,16),Te(X5e,24),Te(Q5e,24))};static#t=this.\u0275pipe=vn({name:"date",type:t,pure:!0,standalone:!0})}return t})(),nT=(()=>{class t{constructor(e){this.differs=e,this.keyValues=[],this.compareFn=XV}transform(e,i=XV){if(!e||!(e instanceof Map)&&"object"!=typeof e)return null;this.differ||(this.differ=this.differs.find(e).create());const r=this.differ.diff(e),s=i!==this.compareFn;return r&&(this.keyValues=[],r.forEachItem(a=>{this.keyValues.push(function ife(t,n){return{key:t,value:n}}(a.key,a.currentValue))})),(r||s)&&(this.keyValues.sort(i),this.compareFn=i),this.keyValues}static#e=this.\u0275fac=function(i){return new(i||t)(Te(n8,16))};static#t=this.\u0275pipe=vn({name:"keyvalue",type:t,pure:!1,standalone:!0})}return t})();function XV(t,n){const e=t.key,i=n.key;if(e===i)return 0;if(void 0===e)return 1;if(void 0===i)return-1;if(null===e)return 1;if(null===i)return-1;if("string"==typeof e&&"string"==typeof i)return e<i?-1:1;if("number"==typeof e&&"number"==typeof i)return e-i;if("boolean"==typeof e&&"boolean"==typeof i)return e<i?-1:1;const r=String(e),s=String(i);return r==s?0:r<s?-1:1}let QV=(()=>{class t{constructor(e){this._locale=e}transform(e,i,r){if(!function iT(t){return!(null==t||""===t||t!=t)}(e))return null;r=r||this._locale;try{return function I5e(t,n,e){return function Kx(t,n,e,i,r,s,a=!1){let o="",c=!1;if(isFinite(t)){let l=function N5e(t){let i,r,s,a,o,n=Math.abs(t)+"",e=0;for((r=n.indexOf("."))>-1&&(n=n.replace(".","")),(s=n.search(/e/i))>0?(r<0&&(r=s),r+=+n.slice(s+1),n=n.substring(0,s)):r<0&&(r=n.length),s=0;"0"===n.charAt(s);s++);if(s===(o=n.length))i=[0],r=1;else{for(o--;"0"===n.charAt(o);)o--;for(r-=s,i=[],a=0;s<=o;s++,a++)i[a]=Number(n.charAt(s))}return r>22&&(i=i.splice(0,21),e=r-1,r=1),{digits:i,exponent:e,integerLen:r}}(t);a&&(l=function D5e(t){if(0===t.digits[0])return t;const n=t.digits.length-t.integerLen;return t.exponent?t.exponent+=2:(0===n?t.digits.push(0,0):1===n&&t.digits.push(0),t.integerLen+=2),t}(l));let u=n.minInt,d=n.minFrac,h=n.maxFrac;if(s){const Ce=s.match(T5e);if(null===Ce)throw new Error(`${s} is not a valid digit info`);const Ve=Ce[1],Fe=Ce[3],qe=Ce[5];null!=Ve&&(u=Qx(Ve)),null!=Fe&&(d=Qx(Fe)),null!=qe?h=Qx(qe):null!=Fe&&d>h&&(h=d)}!function R5e(t,n,e){if(n>e)throw new Error(`The minimum number of digits after fraction (${n}) is higher than the maximum (${e}).`);let i=t.digits,r=i.length-t.integerLen;const s=Math.min(Math.max(n,r),e);let a=s+t.integerLen,o=i[a];if(a>0){i.splice(Math.max(t.integerLen,a));for(let d=a;d<i.length;d++)i[d]=0}else{r=Math.max(0,r),t.integerLen=1,i.length=Math.max(1,a=s+1),i[0]=0;for(let d=1;d<a;d++)i[d]=0}if(o>=5)if(a-1<0){for(let d=0;d>a;d--)i.unshift(0),t.integerLen++;i.unshift(1),t.integerLen++}else i[a-1]++;for(;r<Math.max(0,s);r++)i.push(0);let c=0!==s;const l=n+t.integerLen,u=i.reduceRight(function(d,h,y,I){return I[y]=(h+=d)<10?h:h-10,c&&(0===I[y]&&y>=l?I.pop():c=!1),h>=10?1:0},0);u&&(i.unshift(u),t.integerLen++)}(l,d,h);let y=l.digits,I=l.integerLen;const D=l.exponent;let V=[];for(c=y.every(Ce=>!Ce);I<u;I++)y.unshift(0);for(;I<0;I++)y.unshift(0);I>0?V=y.splice(I,y.length):(V=y,y=[0]);const we=[];for(y.length>=n.lgSize&&we.unshift(y.splice(-n.lgSize,y.length).join(""));y.length>n.gSize;)we.unshift(y.splice(-n.gSize,y.length).join(""));y.length&&we.unshift(y.join("")),o=we.join(J1(e,i)),V.length&&(o+=J1(e,r)+V.join("")),D&&(o+=J1(e,_s.Exponential)+"+"+D)}else o=J1(e,_s.Infinity);return o=t<0&&!c?n.negPre+o+n.negSuf:n.posPre+o+n.posSuf,o}(t,function Xx(t,n="-"){const e={minInt:1,minFrac:0,maxFrac:0,posPre:"",posSuf:"",negPre:"",negSuf:"",gSize:0,lgSize:0},i=t.split(";"),r=i[0],s=i[1],a=-1!==r.indexOf(".")?r.split("."):[r.substring(0,r.lastIndexOf("0")+1),r.substring(r.lastIndexOf("0")+1)],o=a[0],c=a[1]||"";e.posPre=o.substring(0,o.indexOf("#"));for(let u=0;u<c.length;u++){const d=c.charAt(u);"0"===d?e.minFrac=e.maxFrac=u+1:"#"===d?e.maxFrac=u+1:e.posSuf+=d}const l=o.split(",");if(e.gSize=l[1]?l[1].length:0,e.lgSize=l[2]||l[1]?(l[2]||l[1]).length:0,s){const u=r.length-e.posPre.length-e.posSuf.length,d=s.indexOf("#");e.negPre=s.substring(0,d).replace(/'/g,""),e.negSuf=s.slice(d+u).replace(/'/g,"")}else e.negPre=n+e.posPre,e.negSuf=e.posSuf;return e}(function Wx(t,n){return ro(t)[zr.NumberFormats][n]}(n,I9.Decimal),J1(n,_s.MinusSign)),n,_s.Group,_s.Decimal,e)}(function rT(t){if("string"==typeof t&&!isNaN(Number(t)-parseFloat(t)))return Number(t);if("number"!=typeof t)throw new Error(`${t} is not a number`);return t}(e),r,i)}catch(s){throw O2()}}static#e=this.\u0275fac=function(i){return new(i||t)(Te(Q1,16))};static#t=this.\u0275pipe=vn({name:"number",type:t,pure:!0,standalone:!0})}return t})();let s8=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();const JV="browser";function eF(t){return"server"===t}let ufe=(()=>{class t{static#e=this.\u0275prov=Pt({token:t,providedIn:"root",factory:()=>new dfe(gt(Pi),window)})}return t})();class dfe{constructor(n,e){this.document=n,this.window=e,this.offset=()=>[0,0]}setOffset(n){this.offset=Array.isArray(n)?()=>n:n}getScrollPosition(){return this.supportsScrolling()?[this.window.pageXOffset,this.window.pageYOffset]:[0,0]}scrollToPosition(n){this.supportsScrolling()&&this.window.scrollTo(n[0],n[1])}scrollToAnchor(n){if(!this.supportsScrolling())return;const e=function ffe(t,n){const e=t.getElementById(n)||t.getElementsByName(n)[0];if(e)return e;if("function"==typeof t.createTreeWalker&&t.body&&"function"==typeof t.body.attachShadow){const i=t.createTreeWalker(t.body,NodeFilter.SHOW_ELEMENT);let r=i.currentNode;for(;r;){const s=r.shadowRoot;if(s){const a=s.getElementById(n)||s.querySelector(`[name="${n}"]`);if(a)return a}r=i.nextNode()}}return null}(this.document,n);e&&(this.scrollToElement(e),e.focus())}setHistoryScrollRestoration(n){this.supportsScrolling()&&(this.window.history.scrollRestoration=n)}scrollToElement(n){const e=n.getBoundingClientRect(),i=e.left+this.window.pageXOffset,r=e.top+this.window.pageYOffset,s=this.offset();this.window.scrollTo(i-s[0],r-s[1])}supportsScrolling(){try{return!!this.window&&!!this.window.scrollTo&&"pageXOffset"in this.window}catch{return!1}}}class zfe extends Zde{constructor(){super(...arguments),this.supportsDOMEvents=!0}}class oT extends zfe{static makeCurrent(){!function Gde(t){Fx||(Fx=t)}(new oT)}onAndCancel(n,e,i){return n.addEventListener(e,i),()=>{n.removeEventListener(e,i)}}dispatchEvent(n,e){n.dispatchEvent(e)}remove(n){n.parentNode&&n.parentNode.removeChild(n)}createElement(n,e){return(e=e||this.getDefaultDocument()).createElement(n)}createHtmlDocument(){return document.implementation.createHTMLDocument("fakeTitle")}getDefaultDocument(){return document}isElementNode(n){return n.nodeType===Node.ELEMENT_NODE}isShadowRoot(n){return n instanceof DocumentFragment}getGlobalEventTarget(n,e){return"window"===e?window:"document"===e?n:"body"===e?n.body:null}getBaseHref(n){const e=function Ofe(){return o8=o8||document.querySelector("base"),o8?o8.getAttribute("href"):null}();return null==e?null:function Hfe(t){j9=j9||document.createElement("a"),j9.setAttribute("href",t);const n=j9.pathname;return"/"===n.charAt(0)?n:`/${n}`}(e)}resetBaseElement(){o8=null}getUserAgent(){return window.navigator.userAgent}getCookie(n){return function P5e(t,n){n=encodeURIComponent(n);for(const e of t.split(";")){const i=e.indexOf("="),[r,s]=-1==i?[e,""]:[e.slice(0,i),e.slice(i+1)];if(r.trim()===n)return decodeURIComponent(s)}return null}(document.cookie,n)}}let j9,o8=null,Ffe=(()=>{class t{build(){return new XMLHttpRequest}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();const cT=new Jt("EventManagerPlugins");let sF=(()=>{class t{constructor(e,i){this._zone=i,this._eventNameToPlugin=new Map,e.forEach(r=>{r.manager=this}),this._plugins=e.slice().reverse()}addEventListener(e,i,r){return this._findPluginFor(i).addEventListener(e,i,r)}getZone(){return this._zone}_findPluginFor(e){let i=this._eventNameToPlugin.get(e);if(i)return i;if(i=this._plugins.find(s=>s.supports(e)),!i)throw new kt(5101,!1);return this._eventNameToPlugin.set(e,i),i}static#e=this.\u0275fac=function(i){return new(i||t)(gt(cT),gt(Xn))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();class aF{constructor(n){this._doc=n}}const lT="ng-app-id";let oF=(()=>{class t{constructor(e,i,r,s={}){this.doc=e,this.appId=i,this.nonce=r,this.platformId=s,this.styleRef=new Map,this.hostNodes=new Set,this.styleNodesInDOM=this.collectServerRenderedStyles(),this.platformIsServer=eF(s),this.resetHostNodes()}addStyles(e){for(const i of e)1===this.changeUsageCount(i,1)&&this.onStyleAdded(i)}removeStyles(e){for(const i of e)this.changeUsageCount(i,-1)<=0&&this.onStyleRemoved(i)}ngOnDestroy(){const e=this.styleNodesInDOM;e&&(e.forEach(i=>i.remove()),e.clear());for(const i of this.getAllStyles())this.onStyleRemoved(i);this.resetHostNodes()}addHost(e){this.hostNodes.add(e);for(const i of this.getAllStyles())this.addStyleToHost(e,i)}removeHost(e){this.hostNodes.delete(e)}getAllStyles(){return this.styleRef.keys()}onStyleAdded(e){for(const i of this.hostNodes)this.addStyleToHost(i,e)}onStyleRemoved(e){const i=this.styleRef;i.get(e)?.elements?.forEach(r=>r.remove()),i.delete(e)}collectServerRenderedStyles(){const e=this.doc.head?.querySelectorAll(`style[${lT}="${this.appId}"]`);if(e?.length){const i=new Map;return e.forEach(r=>{null!=r.textContent&&i.set(r.textContent,r)}),i}return null}changeUsageCount(e,i){const r=this.styleRef;if(r.has(e)){const s=r.get(e);return s.usage+=i,s.usage}return r.set(e,{usage:i,elements:[]}),i}getStyleElement(e,i){const r=this.styleNodesInDOM,s=r?.get(i);if(s?.parentNode===e)return r.delete(i),s.removeAttribute(lT),s;{const a=this.doc.createElement("style");return this.nonce&&a.setAttribute("nonce",this.nonce),a.textContent=i,this.platformIsServer&&a.setAttribute(lT,this.appId),a}}addStyleToHost(e,i){const r=this.getStyleElement(e,i);e.appendChild(r);const s=this.styleRef,a=s.get(i)?.elements;a?a.push(r):s.set(i,{elements:[r],usage:1})}resetHostNodes(){const e=this.hostNodes;e.clear(),e.add(this.doc.head)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi),gt(Af),gt(gC,8),gt(l4))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();const uT={svg:"http://www.w3.org/2000/svg",xhtml:"http://www.w3.org/1999/xhtml",xlink:"http://www.w3.org/1999/xlink",xml:"http://www.w3.org/XML/1998/namespace",xmlns:"http://www.w3.org/2000/xmlns/",math:"http://www.w3.org/1998/MathML/"},dT=/%COMP%/g,jfe=new Jt("RemoveStylesOnCompDestroy",{providedIn:"root",factory:()=>!1});function lF(t,n){return n.map(e=>e.replace(dT,t))}let fT=(()=>{class t{constructor(e,i,r,s,a,o,c,l=null){this.eventManager=e,this.sharedStylesHost=i,this.appId=r,this.removeStylesOnCompDestroy=s,this.doc=a,this.platformId=o,this.ngZone=c,this.nonce=l,this.rendererByCompId=new Map,this.platformIsServer=eF(o),this.defaultRenderer=new hT(e,a,c,this.platformIsServer)}createRenderer(e,i){if(!e||!i)return this.defaultRenderer;this.platformIsServer&&i.encapsulation===Co.ShadowDom&&(i={...i,encapsulation:Co.Emulated});const r=this.getOrCreateRenderer(e,i);return r instanceof dF?r.applyToHost(e):r instanceof pT&&r.applyStyles(),r}getOrCreateRenderer(e,i){const r=this.rendererByCompId;let s=r.get(i.id);if(!s){const a=this.doc,o=this.ngZone,c=this.eventManager,l=this.sharedStylesHost,u=this.removeStylesOnCompDestroy,d=this.platformIsServer;switch(i.encapsulation){case Co.Emulated:s=new dF(c,l,i,this.appId,u,a,o,d);break;case Co.ShadowDom:return new Zfe(c,l,e,i,a,o,this.nonce,d);default:s=new pT(c,l,i,u,a,o,d)}r.set(i.id,s)}return s}ngOnDestroy(){this.rendererByCompId.clear()}static#e=this.\u0275fac=function(i){return new(i||t)(gt(sF),gt(oF),gt(Af),gt(jfe),gt(Pi),gt(l4),gt(Xn),gt(gC))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();class hT{constructor(n,e,i,r){this.eventManager=n,this.doc=e,this.ngZone=i,this.platformIsServer=r,this.data=Object.create(null),this.destroyNode=null}destroy(){}createElement(n,e){return e?this.doc.createElementNS(uT[e]||e,n):this.doc.createElement(n)}createComment(n){return this.doc.createComment(n)}createText(n){return this.doc.createTextNode(n)}appendChild(n,e){(uF(n)?n.content:n).appendChild(e)}insertBefore(n,e,i){n&&(uF(n)?n.content:n).insertBefore(e,i)}removeChild(n,e){n&&n.removeChild(e)}selectRootElement(n,e){let i="string"==typeof n?this.doc.querySelector(n):n;if(!i)throw new kt(-5104,!1);return e||(i.textContent=""),i}parentNode(n){return n.parentNode}nextSibling(n){return n.nextSibling}setAttribute(n,e,i,r){if(r){e=r+":"+e;const s=uT[r];s?n.setAttributeNS(s,e,i):n.setAttribute(e,i)}else n.setAttribute(e,i)}removeAttribute(n,e,i){if(i){const r=uT[i];r?n.removeAttributeNS(r,e):n.removeAttribute(`${i}:${e}`)}else n.removeAttribute(e)}addClass(n,e){n.classList.add(e)}removeClass(n,e){n.classList.remove(e)}setStyle(n,e,i,r){r&(S3.DashCase|S3.Important)?n.style.setProperty(e,i,r&S3.Important?"important":""):n.style[e]=i}removeStyle(n,e,i){i&S3.DashCase?n.style.removeProperty(e):n.style[e]=""}setProperty(n,e,i){n[e]=i}setValue(n,e){n.nodeValue=e}listen(n,e,i){if("string"==typeof n&&!(n=I3().getGlobalEventTarget(this.doc,n)))throw new Error(`Unsupported event target ${n} for event ${e}`);return this.eventManager.addEventListener(n,e,this.decoratePreventDefault(i))}decoratePreventDefault(n){return e=>{if("__ngUnwrap__"===e)return n;!1===(this.platformIsServer?this.ngZone.runGuarded(()=>n(e)):n(e))&&e.preventDefault()}}}function uF(t){return"TEMPLATE"===t.tagName&&void 0!==t.content}class Zfe extends hT{constructor(n,e,i,r,s,a,o,c){super(n,s,a,c),this.sharedStylesHost=e,this.hostEl=i,this.shadowRoot=i.attachShadow({mode:"open"}),this.sharedStylesHost.addHost(this.shadowRoot);const l=lF(r.id,r.styles);for(const u of l){const d=document.createElement("style");o&&d.setAttribute("nonce",o),d.textContent=u,this.shadowRoot.appendChild(d)}}nodeOrShadowRoot(n){return n===this.hostEl?this.shadowRoot:n}appendChild(n,e){return super.appendChild(this.nodeOrShadowRoot(n),e)}insertBefore(n,e,i){return super.insertBefore(this.nodeOrShadowRoot(n),e,i)}removeChild(n,e){return super.removeChild(this.nodeOrShadowRoot(n),e)}parentNode(n){return this.nodeOrShadowRoot(super.parentNode(this.nodeOrShadowRoot(n)))}destroy(){this.sharedStylesHost.removeHost(this.shadowRoot)}}class pT extends hT{constructor(n,e,i,r,s,a,o,c){super(n,s,a,o),this.sharedStylesHost=e,this.removeStylesOnCompDestroy=r,this.styles=c?lF(c,i.styles):i.styles}applyStyles(){this.sharedStylesHost.addStyles(this.styles)}destroy(){this.removeStylesOnCompDestroy&&this.sharedStylesHost.removeStyles(this.styles)}}class dF extends pT{constructor(n,e,i,r,s,a,o,c){const l=r+"-"+i.id;super(n,e,i,s,a,o,c,l),this.contentAttr=function Wfe(t){return"_ngcontent-%COMP%".replace(dT,t)}(l),this.hostAttr=function qfe(t){return"_nghost-%COMP%".replace(dT,t)}(l)}applyToHost(n){this.applyStyles(),this.setAttribute(n,this.hostAttr,"")}createElement(n,e){const i=super.createElement(n,e);return super.setAttribute(i,this.contentAttr,""),i}}let Yfe=(()=>{class t extends aF{constructor(e){super(e)}supports(e){return!0}addEventListener(e,i,r){return e.addEventListener(i,r,!1),()=>this.removeEventListener(e,i,r)}removeEventListener(e,i,r){return e.removeEventListener(i,r)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();const fF=["alt","control","meta","shift"],Kfe={"\b":"Backspace","\t":"Tab","\x7f":"Delete","\x1b":"Escape",Del:"Delete",Esc:"Escape",Left:"ArrowLeft",Right:"ArrowRight",Up:"ArrowUp",Down:"ArrowDown",Menu:"ContextMenu",Scroll:"ScrollLock",Win:"OS"},Xfe={alt:t=>t.altKey,control:t=>t.ctrlKey,meta:t=>t.metaKey,shift:t=>t.shiftKey};let Qfe=(()=>{class t extends aF{constructor(e){super(e)}supports(e){return null!=t.parseEventName(e)}addEventListener(e,i,r){const s=t.parseEventName(i),a=t.eventCallback(s.fullKey,r,this.manager.getZone());return this.manager.getZone().runOutsideAngular(()=>I3().onAndCancel(e,s.domEventName,a))}static parseEventName(e){const i=e.toLowerCase().split("."),r=i.shift();if(0===i.length||"keydown"!==r&&"keyup"!==r)return null;const s=t._normalizeKey(i.pop());let a="",o=i.indexOf("code");if(o>-1&&(i.splice(o,1),a="code."),fF.forEach(l=>{const u=i.indexOf(l);u>-1&&(i.splice(u,1),a+=l+".")}),a+=s,0!=i.length||0===s.length)return null;const c={};return c.domEventName=r,c.fullKey=a,c}static matchEventFullKeyCode(e,i){let r=Kfe[e.key]||e.key,s="";return i.indexOf("code.")>-1&&(r=e.code,s="code."),!(null==r||!r)&&(r=r.toLowerCase()," "===r?r="space":"."===r&&(r="dot"),fF.forEach(a=>{a!==r&&(0,Xfe[a])(e)&&(s+=a+".")}),s+=r,s===i)}static eventCallback(e,i,r){return s=>{t.matchEventFullKeyCode(s,e)&&r.runGuarded(()=>i(s))}}static _normalizeKey(e){return"esc"===e?"escape":e}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();const pF=[{provide:l4,useValue:JV},{provide:wP,useValue:function Jfe(){oT.makeCurrent()},multi:!0},{provide:Pi,useFactory:function t8e(){return function Qce(t){iC=t}(document),document},deps:[]}],n8e=sV(Rde,"browser",pF),i8e=new Jt(""),mF=[{provide:M9,useClass:class Vfe{addToWindow(n){Mr.getAngularTestability=(i,r=!0)=>{const s=n.findTestabilityInTree(i,r);if(null==s)throw new kt(5103,!1);return s},Mr.getAllAngularTestabilities=()=>n.getAllTestabilities(),Mr.getAllAngularRootElements=()=>n.getAllRootElements(),Mr.frameworkStabilizers||(Mr.frameworkStabilizers=[]),Mr.frameworkStabilizers.push(i=>{const r=Mr.getAllAngularTestabilities();let s=r.length,a=!1;const o=function(c){a=a||c,s--,0==s&&i(a)};r.forEach(c=>{c.whenStable(o)})})}findTestabilityInTree(n,e,i){return null==e?null:n.getTestability(e)??(i?I3().isShadowRoot(e)?this.findTestabilityInTree(n,e.host,!0):this.findTestabilityInTree(n,e.parentElement,!0):null)}},deps:[]},{provide:eV,useClass:Ex,deps:[Xn,Ax,M9]},{provide:Ex,useClass:Ex,deps:[Xn,Ax,M9]}],gF=[{provide:fC,useValue:"root"},{provide:fl,useFactory:function e8e(){return new fl},deps:[]},{provide:cT,useClass:Yfe,multi:!0,deps:[Pi,Xn,l4]},{provide:cT,useClass:Qfe,multi:!0,deps:[Pi]},fT,oF,sF,{provide:S6,useExisting:fT},{provide:class hfe{},useClass:Ffe,deps:[]},[]];let vF=(()=>{class t{constructor(e){}static withServerTransition(e){return{ngModule:t,providers:[{provide:Af,useValue:e.appId}]}}static#e=this.\u0275fac=function(i){return new(i||t)(gt(i8e,12))};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({providers:[...gF,...mF],imports:[s8,Lde]})}return t})(),yF=(()=>{class t{constructor(e){this._doc=e}getTitle(){return this._doc.title}setTitle(e){this._doc.title=e||""}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi))};static#t=this.\u0275prov=Pt({token:t,factory:function(i){let r=null;return r=i?new i:function s8e(){return new yF(gt(Pi))}(),r},providedIn:"root"})}return t})();typeof window<"u"&&window;let gT=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(i){let r=null;return r=i?new(i||t):gt(wF),r},providedIn:"root"})}return t})(),wF=(()=>{class t extends gT{constructor(e){super(),this._doc=e}sanitize(e,i){if(null==i)return null;switch(e){case v1.NONE:return i;case v1.HTML:return dc(i,"HTML")?g1(i):dP(this._doc,String(i)).toString();case v1.STYLE:return dc(i,"Style")?g1(i):i;case v1.SCRIPT:if(dc(i,"Script"))return g1(i);throw new kt(5200,!1);case v1.URL:return dc(i,"URL")?g1(i):Wm(String(i));case v1.RESOURCE_URL:if(dc(i,"ResourceURL"))return g1(i);throw new kt(5201,!1);default:throw new kt(5202,!1)}}bypassSecurityTrustHtml(e){return function sle(t){return new Jce(t)}(e)}bypassSecurityTrustStyle(e){return function ale(t){return new ele(t)}(e)}bypassSecurityTrustScript(e){return function ole(t){return new tle(t)}(e)}bypassSecurityTrustUrl(e){return function cle(t){return new nle(t)}(e)}bypassSecurityTrustResourceUrl(e){return function lle(t){return new ile(t)}(e)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi))};static#t=this.\u0275prov=Pt({token:t,factory:function(i){let r=null;return r=i?new i:function l8e(t){return new wF(t.get(Pi))}(gt(ks)),r},providedIn:"root"})}return t})();const{isArray:u8e}=Array,{getPrototypeOf:d8e,prototype:f8e,keys:h8e}=Object;function xF(t){if(1===t.length){const n=t[0];if(u8e(n))return{args:n,keys:null};if(function p8e(t){return t&&"object"==typeof t&&d8e(t)===f8e}(n)){const e=h8e(n);return{args:e.map(i=>n[i]),keys:e}}}return{args:t,keys:null}}const{isArray:m8e}=Array;function vT(t){return Le(n=>function g8e(t,n){return m8e(n)?t(...n):t(n)}(t,n))}function TF(t,n){return t.reduce((e,i,r)=>(e[i]=n[r],e),{})}let MF=(()=>{class t{constructor(e,i){this._renderer=e,this._elementRef=i,this.onChange=r=>{},this.onTouched=()=>{}}setProperty(e,i){this._renderer.setProperty(this._elementRef.nativeElement,e,i)}registerOnTouched(e){this.onTouched=e}registerOnChange(e){this.onChange=e}setDisabledState(e){this.setProperty("disabled",e)}static#e=this.\u0275fac=function(i){return new(i||t)(Te(Io),Te($n))};static#t=this.\u0275dir=zt({type:t})}return t})(),_4=(()=>{class t extends MF{static#e=this.\u0275fac=function(){let e;return function(r){return(e||(e=Di(t)))(r||t)}}();static#t=this.\u0275dir=zt({type:t,features:[Rn]})}return t})();const Po=new Jt("NgValueAccessor"),_8e={provide:Po,useExisting:_n(()=>W9),multi:!0},w8e=new Jt("CompositionEventMode");let W9=(()=>{class t extends MF{constructor(e,i,r){super(e,i),this._compositionMode=r,this._composing=!1,null==this._compositionMode&&(this._compositionMode=!function b8e(){const t=I3()?I3().getUserAgent():"";return/android (\d+)/.test(t.toLowerCase())}())}writeValue(e){this.setProperty("value",e??"")}_handleInput(e){(!this._compositionMode||this._compositionMode&&!this._composing)&&this.onChange(e)}_compositionStart(){this._composing=!0}_compositionEnd(e){this._composing=!1,this._compositionMode&&this.onChange(e)}static#e=this.\u0275fac=function(i){return new(i||t)(Te(Io),Te($n),Te(w8e,8))};static#t=this.\u0275dir=zt({type:t,selectors:[["input","formControlName","",3,"type","checkbox"],["textarea","formControlName",""],["input","formControl","",3,"type","checkbox"],["textarea","formControl",""],["input","ngModel","",3,"type","checkbox"],["textarea","ngModel",""],["","ngDefaultControl",""]],hostBindings:function(i,r){1&i&&Ee("input",function(a){return r._handleInput(a.target.value)})("blur",function(){return r.onTouched()})("compositionstart",function(){return r._compositionStart()})("compositionend",function(a){return r._compositionEnd(a.target.value)})},features:[ci([_8e]),Rn]})}return t})();const va=new Jt("NgValidators"),R3=new Jt("NgAsyncValidators");function zF(t){return null!=t}function OF(t){return $f(t)?ti(t):t}function HF(t){let n={};return t.forEach(e=>{n=null!=e?{...n,...e}:n}),0===Object.keys(n).length?null:n}function VF(t,n){return n.map(e=>e(t))}function FF(t){return t.map(n=>function x8e(t){return!t.validate}(n)?n:e=>n.validate(e))}function yT(t){return null!=t?function BF(t){if(!t)return null;const n=t.filter(zF);return 0==n.length?null:function(e){return HF(VF(e,n))}}(FF(t)):null}function _T(t){return null!=t?function UF(t){if(!t)return null;const n=t.filter(zF);return 0==n.length?null:function(e){return function v8e(...t){const n=Qt(t),{args:e,keys:i}=xF(t),r=new te(s=>{const{length:a}=e;if(!a)return void s.complete();const o=new Array(a);let c=a,l=a;for(let u=0;u<a;u++){let d=!1;lt(e[u]).subscribe(Ze(s,h=>{d||(d=!0,l--),o[u]=h},()=>c--,void 0,()=>{(!c||!d)&&(l||s.next(i?TF(i,o):o),s.complete())}))}});return n?r.pipe(vT(n)):r}(VF(e,n).map(OF)).pipe(Le(HF))}}(FF(t)):null}function $F(t,n){return null===t?[n]:Array.isArray(t)?[...t,n]:[t,n]}function bT(t){return t?Array.isArray(t)?t:[t]:[]}function G9(t,n){return Array.isArray(t)?t.includes(n):t===n}function qF(t,n){const e=bT(n);return bT(t).forEach(r=>{G9(e,r)||e.push(r)}),e}function GF(t,n){return bT(n).filter(e=>!G9(t,e))}class ZF{constructor(){this._rawValidators=[],this._rawAsyncValidators=[],this._onDestroyCallbacks=[]}get value(){return this.control?this.control.value:null}get valid(){return this.control?this.control.valid:null}get invalid(){return this.control?this.control.invalid:null}get pending(){return this.control?this.control.pending:null}get disabled(){return this.control?this.control.disabled:null}get enabled(){return this.control?this.control.enabled:null}get errors(){return this.control?this.control.errors:null}get pristine(){return this.control?this.control.pristine:null}get dirty(){return this.control?this.control.dirty:null}get touched(){return this.control?this.control.touched:null}get status(){return this.control?this.control.status:null}get untouched(){return this.control?this.control.untouched:null}get statusChanges(){return this.control?this.control.statusChanges:null}get valueChanges(){return this.control?this.control.valueChanges:null}get path(){return null}_setValidators(n){this._rawValidators=n||[],this._composedValidatorFn=yT(this._rawValidators)}_setAsyncValidators(n){this._rawAsyncValidators=n||[],this._composedAsyncValidatorFn=_T(this._rawAsyncValidators)}get validator(){return this._composedValidatorFn||null}get asyncValidator(){return this._composedAsyncValidatorFn||null}_registerOnDestroy(n){this._onDestroyCallbacks.push(n)}_invokeOnDestroyCallbacks(){this._onDestroyCallbacks.forEach(n=>n()),this._onDestroyCallbacks=[]}reset(n=void 0){this.control&&this.control.reset(n)}hasError(n,e){return!!this.control&&this.control.hasError(n,e)}getError(n,e){return this.control?this.control.getError(n,e):null}}class ao extends ZF{get formDirective(){return null}get path(){return null}}class L3 extends ZF{constructor(){super(...arguments),this._parent=null,this.name=null,this.valueAccessor=null}}class YF{constructor(n){this._cd=n}get isTouched(){return!!this._cd?.control?.touched}get isUntouched(){return!!this._cd?.control?.untouched}get isPristine(){return!!this._cd?.control?.pristine}get isDirty(){return!!this._cd?.control?.dirty}get isValid(){return!!this._cd?.control?.valid}get isInvalid(){return!!this._cd?.control?.invalid}get isPending(){return!!this._cd?.control?.pending}get isSubmitted(){return!!this._cd?.submitted}}let KF=(()=>{class t extends YF{constructor(e){super(e)}static#e=this.\u0275fac=function(i){return new(i||t)(Te(L3,2))};static#t=this.\u0275dir=zt({type:t,selectors:[["","formControlName",""],["","ngModel",""],["","formControl",""]],hostVars:14,hostBindings:function(i,r){2&i&&Li("ng-untouched",r.isUntouched)("ng-touched",r.isTouched)("ng-pristine",r.isPristine)("ng-dirty",r.isDirty)("ng-valid",r.isValid)("ng-invalid",r.isInvalid)("ng-pending",r.isPending)},features:[Rn]})}return t})();const c8="VALID",Y9="INVALID",Y6="PENDING",l8="DISABLED";function K9(t){return null!=t&&!Array.isArray(t)&&"object"==typeof t}class eB{constructor(n,e){this._pendingDirty=!1,this._hasOwnPendingAsyncValidator=!1,this._pendingTouched=!1,this._onCollectionChange=()=>{},this._parent=null,this.pristine=!0,this.touched=!1,this._onDisabledChange=[],this._assignValidators(n),this._assignAsyncValidators(e)}get validator(){return this._composedValidatorFn}set validator(n){this._rawValidators=this._composedValidatorFn=n}get asyncValidator(){return this._composedAsyncValidatorFn}set asyncValidator(n){this._rawAsyncValidators=this._composedAsyncValidatorFn=n}get parent(){return this._parent}get valid(){return this.status===c8}get invalid(){return this.status===Y9}get pending(){return this.status==Y6}get disabled(){return this.status===l8}get enabled(){return this.status!==l8}get dirty(){return!this.pristine}get untouched(){return!this.touched}get updateOn(){return this._updateOn?this._updateOn:this.parent?this.parent.updateOn:"change"}setValidators(n){this._assignValidators(n)}setAsyncValidators(n){this._assignAsyncValidators(n)}addValidators(n){this.setValidators(qF(n,this._rawValidators))}addAsyncValidators(n){this.setAsyncValidators(qF(n,this._rawAsyncValidators))}removeValidators(n){this.setValidators(GF(n,this._rawValidators))}removeAsyncValidators(n){this.setAsyncValidators(GF(n,this._rawAsyncValidators))}hasValidator(n){return G9(this._rawValidators,n)}hasAsyncValidator(n){return G9(this._rawAsyncValidators,n)}clearValidators(){this.validator=null}clearAsyncValidators(){this.asyncValidator=null}markAsTouched(n={}){this.touched=!0,this._parent&&!n.onlySelf&&this._parent.markAsTouched(n)}markAllAsTouched(){this.markAsTouched({onlySelf:!0}),this._forEachChild(n=>n.markAllAsTouched())}markAsUntouched(n={}){this.touched=!1,this._pendingTouched=!1,this._forEachChild(e=>{e.markAsUntouched({onlySelf:!0})}),this._parent&&!n.onlySelf&&this._parent._updateTouched(n)}markAsDirty(n={}){this.pristine=!1,this._parent&&!n.onlySelf&&this._parent.markAsDirty(n)}markAsPristine(n={}){this.pristine=!0,this._pendingDirty=!1,this._forEachChild(e=>{e.markAsPristine({onlySelf:!0})}),this._parent&&!n.onlySelf&&this._parent._updatePristine(n)}markAsPending(n={}){this.status=Y6,!1!==n.emitEvent&&this.statusChanges.emit(this.status),this._parent&&!n.onlySelf&&this._parent.markAsPending(n)}disable(n={}){const e=this._parentMarkedDirty(n.onlySelf);this.status=l8,this.errors=null,this._forEachChild(i=>{i.disable({...n,onlySelf:!0})}),this._updateValue(),!1!==n.emitEvent&&(this.valueChanges.emit(this.value),this.statusChanges.emit(this.status)),this._updateAncestors({...n,skipPristineCheck:e}),this._onDisabledChange.forEach(i=>i(!0))}enable(n={}){const e=this._parentMarkedDirty(n.onlySelf);this.status=c8,this._forEachChild(i=>{i.enable({...n,onlySelf:!0})}),this.updateValueAndValidity({onlySelf:!0,emitEvent:n.emitEvent}),this._updateAncestors({...n,skipPristineCheck:e}),this._onDisabledChange.forEach(i=>i(!1))}_updateAncestors(n){this._parent&&!n.onlySelf&&(this._parent.updateValueAndValidity(n),n.skipPristineCheck||this._parent._updatePristine(),this._parent._updateTouched())}setParent(n){this._parent=n}getRawValue(){return this.value}updateValueAndValidity(n={}){this._setInitialStatus(),this._updateValue(),this.enabled&&(this._cancelExistingSubscription(),this.errors=this._runValidator(),this.status=this._calculateStatus(),(this.status===c8||this.status===Y6)&&this._runAsyncValidator(n.emitEvent)),!1!==n.emitEvent&&(this.valueChanges.emit(this.value),this.statusChanges.emit(this.status)),this._parent&&!n.onlySelf&&this._parent.updateValueAndValidity(n)}_updateTreeValidity(n={emitEvent:!0}){this._forEachChild(e=>e._updateTreeValidity(n)),this.updateValueAndValidity({onlySelf:!0,emitEvent:n.emitEvent})}_setInitialStatus(){this.status=this._allControlsDisabled()?l8:c8}_runValidator(){return this.validator?this.validator(this):null}_runAsyncValidator(n){if(this.asyncValidator){this.status=Y6,this._hasOwnPendingAsyncValidator=!0;const e=OF(this.asyncValidator(this));this._asyncValidationSubscription=e.subscribe(i=>{this._hasOwnPendingAsyncValidator=!1,this.setErrors(i,{emitEvent:n})})}}_cancelExistingSubscription(){this._asyncValidationSubscription&&(this._asyncValidationSubscription.unsubscribe(),this._hasOwnPendingAsyncValidator=!1)}setErrors(n,e={}){this.errors=n,this._updateControlsErrors(!1!==e.emitEvent)}get(n){let e=n;return null==e||(Array.isArray(e)||(e=e.split(".")),0===e.length)?null:e.reduce((i,r)=>i&&i._find(r),this)}getError(n,e){const i=e?this.get(e):this;return i&&i.errors?i.errors[n]:null}hasError(n,e){return!!this.getError(n,e)}get root(){let n=this;for(;n._parent;)n=n._parent;return n}_updateControlsErrors(n){this.status=this._calculateStatus(),n&&this.statusChanges.emit(this.status),this._parent&&this._parent._updateControlsErrors(n)}_initObservables(){this.valueChanges=new Ht,this.statusChanges=new Ht}_calculateStatus(){return this._allControlsDisabled()?l8:this.errors?Y9:this._hasOwnPendingAsyncValidator||this._anyControlsHaveStatus(Y6)?Y6:this._anyControlsHaveStatus(Y9)?Y9:c8}_anyControlsHaveStatus(n){return this._anyControls(e=>e.status===n)}_anyControlsDirty(){return this._anyControls(n=>n.dirty)}_anyControlsTouched(){return this._anyControls(n=>n.touched)}_updatePristine(n={}){this.pristine=!this._anyControlsDirty(),this._parent&&!n.onlySelf&&this._parent._updatePristine(n)}_updateTouched(n={}){this.touched=this._anyControlsTouched(),this._parent&&!n.onlySelf&&this._parent._updateTouched(n)}_registerOnCollectionChange(n){this._onCollectionChange=n}_setUpdateStrategy(n){K9(n)&&null!=n.updateOn&&(this._updateOn=n.updateOn)}_parentMarkedDirty(n){return!n&&!(!this._parent||!this._parent.dirty)&&!this._parent._anyControlsDirty()}_find(n){return null}_assignValidators(n){this._rawValidators=Array.isArray(n)?n.slice():n,this._composedValidatorFn=function E8e(t){return Array.isArray(t)?yT(t):t||null}(this._rawValidators)}_assignAsyncValidators(n){this._rawAsyncValidators=Array.isArray(n)?n.slice():n,this._composedAsyncValidatorFn=function A8e(t){return Array.isArray(t)?_T(t):t||null}(this._rawAsyncValidators)}}const K6=new Jt("CallSetDisabledState",{providedIn:"root",factory:()=>X9}),X9="always";function u8(t,n,e=X9){(function kT(t,n){const e=function jF(t){return t._rawValidators}(t);null!==n.validator?t.setValidators($F(e,n.validator)):"function"==typeof e&&t.setValidators([e]);const i=function WF(t){return t._rawAsyncValidators}(t);null!==n.asyncValidator?t.setAsyncValidators($F(i,n.asyncValidator)):"function"==typeof i&&t.setAsyncValidators([i]);const r=()=>t.updateValueAndValidity();eg(n._rawValidators,r),eg(n._rawAsyncValidators,r)})(t,n),n.valueAccessor.writeValue(t.value),(t.disabled||"always"===e)&&n.valueAccessor.setDisabledState?.(t.disabled),function N8e(t,n){n.valueAccessor.registerOnChange(e=>{t._pendingValue=e,t._pendingChange=!0,t._pendingDirty=!0,"change"===t.updateOn&&tB(t,n)})}(t,n),function L8e(t,n){const e=(i,r)=>{n.valueAccessor.writeValue(i),r&&n.viewToModelUpdate(i)};t.registerOnChange(e),n._registerOnDestroy(()=>{t._unregisterOnChange(e)})}(t,n),function R8e(t,n){n.valueAccessor.registerOnTouched(()=>{t._pendingTouched=!0,"blur"===t.updateOn&&t._pendingChange&&tB(t,n),"submit"!==t.updateOn&&t.markAsTouched()})}(t,n),function D8e(t,n){if(n.valueAccessor.setDisabledState){const e=i=>{n.valueAccessor.setDisabledState(i)};t.registerOnDisabledChange(e),n._registerOnDestroy(()=>{t._unregisterOnDisabledChange(e)})}}(t,n)}function eg(t,n){t.forEach(e=>{e.registerOnValidatorChange&&e.registerOnValidatorChange(n)})}function tB(t,n){t._pendingDirty&&t.markAsDirty(),t.setValue(t._pendingValue,{emitModelToViewChange:!1}),n.viewToModelUpdate(t._pendingValue),t._pendingChange=!1}function rB(t,n){const e=t.indexOf(n);e>-1&&t.splice(e,1)}function sB(t){return"object"==typeof t&&null!==t&&2===Object.keys(t).length&&"value"in t&&"disabled"in t}const aB=class extends eB{constructor(n=null,e,i){super(function xT(t){return(K9(t)?t.validators:t)||null}(e),function TT(t,n){return(K9(n)?n.asyncValidators:t)||null}(i,e)),this.defaultValue=null,this._onChange=[],this._pendingChange=!1,this._applyFormState(n),this._setUpdateStrategy(e),this._initObservables(),this.updateValueAndValidity({onlySelf:!0,emitEvent:!!this.asyncValidator}),K9(e)&&(e.nonNullable||e.initialValueIsDefault)&&(this.defaultValue=sB(n)?n.value:n)}setValue(n,e={}){this.value=this._pendingValue=n,this._onChange.length&&!1!==e.emitModelToViewChange&&this._onChange.forEach(i=>i(this.value,!1!==e.emitViewToModelChange)),this.updateValueAndValidity(e)}patchValue(n,e={}){this.setValue(n,e)}reset(n=this.defaultValue,e={}){this._applyFormState(n),this.markAsPristine(e),this.markAsUntouched(e),this.setValue(this.value,e),this._pendingChange=!1}_updateValue(){}_anyControls(n){return!1}_allControlsDisabled(){return this.disabled}registerOnChange(n){this._onChange.push(n)}_unregisterOnChange(n){rB(this._onChange,n)}registerOnDisabledChange(n){this._onDisabledChange.push(n)}_unregisterOnDisabledChange(n){rB(this._onDisabledChange,n)}_forEachChild(n){}_syncPendingControls(){return!("submit"!==this.updateOn||(this._pendingDirty&&this.markAsDirty(),this._pendingTouched&&this.markAsTouched(),!this._pendingChange)||(this.setValue(this._pendingValue,{onlySelf:!0,emitModelToViewChange:!1}),0))}_applyFormState(n){sB(n)?(this.value=this._pendingValue=n.value,n.disabled?this.disable({onlySelf:!0,emitEvent:!1}):this.enable({onlySelf:!0,emitEvent:!1})):this.value=this._pendingValue=n}},U8e={provide:L3,useExisting:_n(()=>DT)},lB=(()=>Promise.resolve())();let DT=(()=>{class t extends L3{constructor(e,i,r,s,a,o){super(),this._changeDetectorRef=a,this.callSetDisabledState=o,this.control=new aB,this._registered=!1,this.name="",this.update=new Ht,this._parent=e,this._setValidators(i),this._setAsyncValidators(r),this.valueAccessor=function AT(t,n){if(!n)return null;let e,i,r;return Array.isArray(n),n.forEach(s=>{s.constructor===W9?e=s:function O8e(t){return Object.getPrototypeOf(t.constructor)===_4}(s)?i=s:r=s}),r||i||e||null}(0,s)}ngOnChanges(e){if(this._checkForErrors(),!this._registered||"name"in e){if(this._registered&&(this._checkName(),this.formDirective)){const i=e.name.previousValue;this.formDirective.removeControl({name:i,path:this._getPath(i)})}this._setUpControl()}"isDisabled"in e&&this._updateDisabled(e),function ET(t,n){if(!t.hasOwnProperty("model"))return!1;const e=t.model;return!!e.isFirstChange()||!Object.is(n,e.currentValue)}(e,this.viewModel)&&(this._updateValue(this.model),this.viewModel=this.model)}ngOnDestroy(){this.formDirective&&this.formDirective.removeControl(this)}get path(){return this._getPath(this.name)}get formDirective(){return this._parent?this._parent.formDirective:null}viewToModelUpdate(e){this.viewModel=e,this.update.emit(e)}_setUpControl(){this._setUpdateStrategy(),this._isStandalone()?this._setUpStandalone():this.formDirective.addControl(this),this._registered=!0}_setUpdateStrategy(){this.options&&null!=this.options.updateOn&&(this.control._updateOn=this.options.updateOn)}_isStandalone(){return!this._parent||!(!this.options||!this.options.standalone)}_setUpStandalone(){u8(this.control,this,this.callSetDisabledState),this.control.updateValueAndValidity({emitEvent:!1})}_checkForErrors(){this._isStandalone()||this._checkParentType(),this._checkName()}_checkParentType(){}_checkName(){this.options&&this.options.name&&(this.name=this.options.name),this._isStandalone()}_updateValue(e){lB.then(()=>{this.control.setValue(e,{emitViewToModelChange:!1}),this._changeDetectorRef?.markForCheck()})}_updateDisabled(e){const i=e.isDisabled.currentValue,r=0!==i&&q6(i);lB.then(()=>{r&&!this.control.disabled?this.control.disable():!r&&this.control.disabled&&this.control.enable(),this._changeDetectorRef?.markForCheck()})}_getPath(e){return this._parent?function Q9(t,n){return[...n.path,t]}(e,this._parent):[e]}static#e=this.\u0275fac=function(i){return new(i||t)(Te(ao,9),Te(va,10),Te(R3,10),Te(Po,10),Te(Dr,8),Te(K6,8))};static#t=this.\u0275dir=zt({type:t,selectors:[["","ngModel","",3,"formControlName","",3,"formControl",""]],inputs:{name:"name",isDisabled:["disabled","isDisabled"],model:["ngModel","model"],options:["ngModelOptions","options"]},outputs:{update:"ngModelChange"},exportAs:["ngModel"],features:[ci([U8e]),Rn,Un]})}return t})(),dB=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),hhe=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({imports:[dB]})}return t})(),mhe=(()=>{class t{static withConfig(e){return{ngModule:t,providers:[{provide:K6,useValue:e.callSetDisabledState??X9}]}}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({imports:[hhe]})}return t})();const ghe=["addListener","removeListener"],vhe=["addEventListener","removeEventListener"],yhe=["on","off"];function ya(t,n,e,i){if(Y(e)&&(i=e,e=void 0),i)return ya(t,n,e).pipe(vT(i));const[r,s]=function whe(t){return Y(t.addEventListener)&&Y(t.removeEventListener)}(t)?vhe.map(a=>o=>t[a](n,o,e)):function _he(t){return Y(t.addListener)&&Y(t.removeListener)}(t)?ghe.map(AB(t,n)):function bhe(t){return Y(t.on)&&Y(t.off)}(t)?yhe.map(AB(t,n)):[];if(!r&&pe(t))return Ne(a=>ya(a,n,e))(lt(t));if(!r)throw new TypeError("Invalid event target");return new te(a=>{const o=(...c)=>a.next(1<c.length?c:c[0]);return r(o),()=>s(o)})}function AB(t,n){return e=>i=>t[e](n,i)}class Che extends w{constructor(n,e){super()}schedule(n,e=0){return this}}const ng={setInterval(t,n,...e){const{delegate:i}=ng;return i?.setInterval?i.setInterval(t,n,...e):setInterval(t,n,...e)},clearInterval(t){const{delegate:n}=ng;return(n?.clearInterval||clearInterval)(t)},delegate:void 0};class HT extends Che{constructor(n,e){super(n,e),this.scheduler=n,this.work=e,this.pending=!1}schedule(n,e=0){var i;if(this.closed)return this;this.state=n;const r=this.id,s=this.scheduler;return null!=r&&(this.id=this.recycleAsyncId(s,r,e)),this.pending=!0,this.delay=e,this.id=null!==(i=this.id)&&void 0!==i?i:this.requestAsyncId(s,this.id,e),this}requestAsyncId(n,e,i=0){return ng.setInterval(n.flush.bind(n,this),i)}recycleAsyncId(n,e,i=0){if(null!=i&&this.delay===i&&!1===this.pending)return e;null!=e&&ng.clearInterval(e)}execute(n,e){if(this.closed)return new Error("executing a cancelled action");this.pending=!1;const i=this._execute(n,e);if(i)return i;!1===this.pending&&null!=this.id&&(this.id=this.recycleAsyncId(this.scheduler,this.id,null))}_execute(n,e){let r,i=!1;try{this.work(n)}catch(s){i=!0,r=s||new Error("Scheduled action threw falsy error")}if(i)return this.unsubscribe(),r}unsubscribe(){if(!this.closed){const{id:n,scheduler:e}=this,{actions:i}=e;this.work=this.state=this.scheduler=null,this.pending=!1,b(i,this),null!=n&&(this.id=this.recycleAsyncId(e,n,null)),this.delay=null,super.unsubscribe()}}}const IB={now:()=>(IB.delegate||Date).now(),delegate:void 0};class f8{constructor(n,e=f8.now){this.schedulerActionCtor=n,this.now=e}schedule(n,e=0,i){return new this.schedulerActionCtor(this,n).schedule(i,e)}}f8.now=IB.now;class VT extends f8{constructor(n,e=f8.now){super(n,e),this.actions=[],this._active=!1}flush(n){const{actions:e}=this;if(this._active)return void e.push(n);let i;this._active=!0;do{if(i=n.execute(n.state,n.delay))break}while(n=e.shift());if(this._active=!1,i){for(;n=e.shift();)n.unsubscribe();throw i}}}const ig=new VT(HT),xhe=ig;function FT(t=0,n,e=xhe){let i=-1;return null!=n&&(Mn(n)?e=n:i=n),new te(r=>{let s=function The(t){return t instanceof Date&&!isNaN(t)}(t)?+t-e.now():t;s<0&&(s=0);let a=0;return e.schedule(function(){r.closed||(r.next(a++),0<=i?this.schedule(void 0,i):r.complete())},s)})}const{isArray:Mhe}=Array;function DB(t){return 1===t.length&&Mhe(t[0])?t[0]:t}function BT(...t){const n=Qt(t),e=DB(t);return e.length?new te(i=>{let r=e.map(()=>[]),s=e.map(()=>!1);i.add(()=>{r=s=null});for(let a=0;!i.closed&&a<e.length;a++)lt(e[a]).subscribe(Ze(i,o=>{if(r[a].push(o),r.every(c=>c.length)){const c=r.map(l=>l.shift());i.next(n?n(...c):c),r.some((l,u)=>!l.length&&s[u])&&i.complete()}},()=>{s[a]=!0,!r[a].length&&i.complete()}));return()=>{r=s=null}}):pt}function X6(...t){return function She(){return Be(1)}()(ti(t,Zn(t)))}function yr(t){return Ue((n,e)=>{lt(t).subscribe(Ze(e,()=>e.complete(),F)),!e.closed&&n.subscribe(e)})}function ea(t,n){return Ue((e,i)=>{let r=0;e.subscribe(Ze(i,s=>t.call(n,s,r++)&&i.next(s)))})}function Es(t){return t<=0?()=>pt:Ue((n,e)=>{let i=0;n.subscribe(Ze(e,r=>{++i<=t&&(e.next(r),t<=i&&e.complete())}))})}function ta(t,n,e){const i=Y(t)||n||e?{next:t,error:n,complete:e}:t;return i?Ue((r,s)=>{var a;null===(a=i.subscribe)||void 0===a||a.call(i);let o=!0;r.subscribe(Ze(s,c=>{var l;null===(l=i.next)||void 0===l||l.call(i,c),s.next(c)},()=>{var c;o=!1,null===(c=i.complete)||void 0===c||c.call(i),s.complete()},c=>{var l;o=!1,null===(l=i.error)||void 0===l||l.call(i,c),s.error(c)},()=>{var c,l;o&&(null===(c=i.unsubscribe)||void 0===c||c.call(i)),null===(l=i.finalize)||void 0===l||l.call(i)}))}):H}function UT(...t){const n=Qt(t);return Ue((e,i)=>{const r=t.length,s=new Array(r);let a=t.map(()=>!1),o=!1;for(let c=0;c<r;c++)lt(t[c]).subscribe(Ze(i,l=>{s[c]=l,!o&&!a[c]&&(a[c]=!0,(o=a.every(H))&&(a=null))},F));e.subscribe(Ze(i,c=>{if(o){const l=[c,...s];i.next(n?n(...l):l)}}))})}function $T(...t){const n=Zn(t);return Ue((e,i)=>{(n?X6(t,e,n):X6(t,e)).subscribe(i)})}function jT(t){return ea((n,e)=>t<=e)}Math,Math,Math;const i7e=["*"],R7e=["dialog"];function x4(t){return"string"==typeof t}function T4(t){return null!=t}function id(t){return(t||document.body).getBoundingClientRect()}const dU={animation:!0,transitionTimerDelayMs:5},Mme=()=>{},{transitionTimerDelayMs:kme}=dU,b8=new Map,Ho=(t,n,e,i)=>{let r=i.context||{};const s=b8.get(n);if(s)switch(i.runningTransition){case"continue":return pt;case"stop":t.run(()=>s.transition$.complete()),r=Object.assign(s.context,r),b8.delete(n)}const a=e(n,i.animation,r)||Mme;if(!i.animation||"none"===window.getComputedStyle(n).transitionProperty)return t.run(()=>a()),ln(void 0).pipe(function xme(t){return n=>new te(e=>n.subscribe({next:a=>t.run(()=>e.next(a)),error:a=>t.run(()=>e.error(a)),complete:()=>t.run(()=>e.complete())}))}(t));const o=new U,c=new U,l=o.pipe(function Ehe(...t){return n=>X6(n,ln(...t))}(!0));b8.set(n,{transition$:o,complete:()=>{c.next(),c.complete()},context:r});const u=function Tme(t){const{transitionDelay:n,transitionDuration:e}=window.getComputedStyle(t);return 1e3*(parseFloat(n)+parseFloat(e))}(n);return t.runOutsideAngular(()=>{const d=ya(n,"transitionend").pipe(yr(l),ea(({target:y})=>y===n));(function NB(...t){return 1===(t=DB(t)).length?lt(t[0]):new te(function khe(t){return n=>{let e=[];for(let i=0;e&&!n.closed&&i<t.length;i++)e.push(lt(t[i]).subscribe(Ze(n,r=>{if(e){for(let s=0;s<e.length;s++)s!==i&&e[s].unsubscribe();e=null}n.next(r)})))}}(t))})(FT(u+kme).pipe(yr(l)),d,c).pipe(yr(l)).subscribe(()=>{b8.delete(n),t.run(()=>{a(),o.next(),o.complete()})})}),o.asObservable()};let dg=(()=>{class t{constructor(){this.animation=dU.animation}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),bU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),wU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),TU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),MU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();var Nr=function(t){return t[t.Tab=9]="Tab",t[t.Enter=13]="Enter",t[t.Escape=27]="Escape",t[t.Space=32]="Space",t[t.PageUp=33]="PageUp",t[t.PageDown=34]="PageDown",t[t.End=35]="End",t[t.Home=36]="Home",t[t.ArrowLeft=37]="ArrowLeft",t[t.ArrowUp=38]="ArrowUp",t[t.ArrowRight=39]="ArrowRight",t[t.ArrowDown=40]="ArrowDown",t}(Nr||{});typeof navigator<"u"&&navigator.userAgent&&(/iPad|iPhone|iPod/.test(navigator.userAgent)||/Macintosh/.test(navigator.userAgent)&&navigator.maxTouchPoints&&navigator.maxTouchPoints>2||/Android/.test(navigator.userAgent));const NU=["a[href]","button:not([disabled])",'input:not([disabled]):not([type="hidden"])',"select:not([disabled])","textarea:not([disabled])","[contenteditable]",'[tabindex]:not([tabindex="-1"])'].join(", ");function RU(t){const n=Array.from(t.querySelectorAll(NU)).filter(e=>-1!==e.tabIndex);return[n[0],n[n.length-1]]}new Date(1882,10,12),new Date(2174,10,25);let qU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),YU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();class A4{constructor(n,e,i){this.nodes=n,this.viewRef=e,this.componentRef=i}}let M9e=(()=>{class t{constructor(e,i){this._el=e,this._zone=i}ngOnInit(){this._zone.onStable.asObservable().pipe(Es(1)).subscribe(()=>{Ho(this._zone,this._el.nativeElement,(e,i)=>{i&&id(e),e.classList.add("show")},{animation:this.animation,runningTransition:"continue"})})}hide(){return Ho(this._zone,this._el.nativeElement,({classList:e})=>e.remove("show"),{animation:this.animation,runningTransition:"stop"})}static#e=this.\u0275fac=function(i){return new(i||t)(Te($n),Te(Xn))};static#t=this.\u0275cmp=Nt({type:t,selectors:[["ngb-modal-backdrop"]],hostAttrs:[2,"z-index","1055"],hostVars:6,hostBindings:function(i,r){2&i&&(io("modal-backdrop"+(r.backdropClass?" "+r.backdropClass:"")),Li("show",!r.animation)("fade",r.animation))},inputs:{animation:"animation",backdropClass:"backdropClass"},standalone:!0,features:[Ro],decls:0,vars:0,template:function(i,r){},encapsulation:2})}return t})();class ad{update(n){}close(n){}dismiss(n){}}const k9e=["animation","ariaLabelledBy","ariaDescribedBy","backdrop","centered","fullscreen","keyboard","scrollable","size","windowClass","modalDialogClass"],S9e=["animation","backdropClass"];class E9e{_applyWindowOptions(n,e){k9e.forEach(i=>{T4(e[i])&&(n[i]=e[i])})}_applyBackdropOptions(n,e){S9e.forEach(i=>{T4(e[i])&&(n[i]=e[i])})}update(n){this._applyWindowOptions(this._windowCmptRef.instance,n),this._backdropCmptRef&&this._backdropCmptRef.instance&&this._applyBackdropOptions(this._backdropCmptRef.instance,n)}get componentInstance(){if(this._contentRef&&this._contentRef.componentRef)return this._contentRef.componentRef.instance}get closed(){return this._closed.asObservable().pipe(yr(this._hidden))}get dismissed(){return this._dismissed.asObservable().pipe(yr(this._hidden))}get hidden(){return this._hidden.asObservable()}get shown(){return this._windowCmptRef.instance.shown.asObservable()}constructor(n,e,i,r){this._windowCmptRef=n,this._contentRef=e,this._backdropCmptRef=i,this._beforeDismiss=r,this._closed=new U,this._dismissed=new U,this._hidden=new U,n.instance.dismissEvent.subscribe(s=>{this.dismiss(s)}),this.result=new Promise((s,a)=>{this._resolve=s,this._reject=a}),this.result.then(null,()=>{})}close(n){this._windowCmptRef&&(this._closed.next(n),this._resolve(n),this._removeModalElements())}_dismiss(n){this._dismissed.next(n),this._reject(n),this._removeModalElements()}dismiss(n){if(this._windowCmptRef)if(this._beforeDismiss){const e=this._beforeDismiss();!function cU(t){return t&&t.then}(e)?!1!==e&&this._dismiss(n):e.then(i=>{!1!==i&&this._dismiss(n)},()=>{})}else this._dismiss(n)}_removeModalElements(){const n=this._windowCmptRef.instance.hide(),e=this._backdropCmptRef?this._backdropCmptRef.instance.hide():ln(void 0);n.subscribe(()=>{const{nativeElement:i}=this._windowCmptRef.location;i.parentNode.removeChild(i),this._windowCmptRef.destroy(),this._contentRef&&this._contentRef.viewRef&&this._contentRef.viewRef.destroy(),this._windowCmptRef=null,this._contentRef=null}),e.subscribe(()=>{if(this._backdropCmptRef){const{nativeElement:i}=this._backdropCmptRef.location;i.parentNode.removeChild(i),this._backdropCmptRef.destroy(),this._backdropCmptRef=null}}),BT(n,e).subscribe(()=>{this._hidden.next(),this._hidden.complete()})}}var yM=function(t){return t[t.BACKDROP_CLICK=0]="BACKDROP_CLICK",t[t.ESC=1]="ESC",t}(yM||{});let A9e=(()=>{class t{constructor(e,i,r){this._document=e,this._elRef=i,this._zone=r,this._closed$=new U,this._elWithFocus=null,this.backdrop=!0,this.keyboard=!0,this.dismissEvent=new Ht,this.shown=new U,this.hidden=new U}get fullscreenClass(){return!0===this.fullscreen?" modal-fullscreen":x4(this.fullscreen)?` modal-fullscreen-${this.fullscreen}-down`:""}dismiss(e){this.dismissEvent.emit(e)}ngOnInit(){this._elWithFocus=this._document.activeElement,this._zone.onStable.asObservable().pipe(Es(1)).subscribe(()=>{this._show()})}ngOnDestroy(){this._disableEventHandling()}hide(){const{nativeElement:e}=this._elRef,i={animation:this.animation,runningTransition:"stop"},a=BT(Ho(this._zone,e,()=>e.classList.remove("show"),i),Ho(this._zone,this._dialogEl.nativeElement,()=>{},i));return a.subscribe(()=>{this.hidden.next(),this.hidden.complete()}),this._disableEventHandling(),this._restoreFocus(),a}_show(){const e={animation:this.animation,runningTransition:"continue"};BT(Ho(this._zone,this._elRef.nativeElement,(s,a)=>{a&&id(s),s.classList.add("show")},e),Ho(this._zone,this._dialogEl.nativeElement,()=>{},e)).subscribe(()=>{this.shown.next(),this.shown.complete()}),this._enableEventHandling(),this._setFocus()}_enableEventHandling(){const{nativeElement:e}=this._elRef;this._zone.runOutsideAngular(()=>{ya(e,"keydown").pipe(yr(this._closed$),ea(r=>r.which===Nr.Escape)).subscribe(r=>{this.keyboard?requestAnimationFrame(()=>{r.defaultPrevented||this._zone.run(()=>this.dismiss(yM.ESC))}):"static"===this.backdrop&&this._bumpBackdrop()});let i=!1;ya(this._dialogEl.nativeElement,"mousedown").pipe(yr(this._closed$),ta(()=>i=!1),vi(()=>ya(e,"mouseup").pipe(yr(this._closed$),Es(1))),ea(({target:r})=>e===r)).subscribe(()=>{i=!0}),ya(e,"click").pipe(yr(this._closed$)).subscribe(({target:r})=>{e===r&&("static"===this.backdrop?this._bumpBackdrop():!0===this.backdrop&&!i&&this._zone.run(()=>this.dismiss(yM.BACKDROP_CLICK))),i=!1})})}_disableEventHandling(){this._closed$.next()}_setFocus(){const{nativeElement:e}=this._elRef;if(!e.contains(document.activeElement)){const i=e.querySelector("[ngbAutofocus]"),r=RU(e)[0];(i||r||e).focus()}}_restoreFocus(){const e=this._document.body,i=this._elWithFocus;let r;r=i&&i.focus&&e.contains(i)?i:e,this._zone.runOutsideAngular(()=>{setTimeout(()=>r.focus()),this._elWithFocus=null})}_bumpBackdrop(){"static"===this.backdrop&&Ho(this._zone,this._elRef.nativeElement,({classList:e})=>(e.add("modal-static"),()=>e.remove("modal-static")),{animation:this.animation,runningTransition:"continue"})}static#e=this.\u0275fac=function(i){return new(i||t)(Te(Pi),Te($n),Te(Xn))};static#t=this.\u0275cmp=Nt({type:t,selectors:[["ngb-modal-window"]],viewQuery:function(i,r){if(1&i&&Cn(R7e,7),2&i){let s;qt(s=Gt())&&(r._dialogEl=s.first)}},hostAttrs:["role","dialog","tabindex","-1"],hostVars:7,hostBindings:function(i,r){2&i&&(pi("aria-modal",!0)("aria-labelledby",r.ariaLabelledBy)("aria-describedby",r.ariaDescribedBy),io("modal d-block"+(r.windowClass?" "+r.windowClass:"")),Li("fade",r.animation))},inputs:{animation:"animation",ariaLabelledBy:"ariaLabelledBy",ariaDescribedBy:"ariaDescribedBy",backdrop:"backdrop",centered:"centered",fullscreen:"fullscreen",keyboard:"keyboard",scrollable:"scrollable",size:"size",windowClass:"windowClass",modalDialogClass:"modalDialogClass"},outputs:{dismissEvent:"dismiss"},standalone:!0,features:[Ro],ngContentSelectors:i7e,decls:4,vars:2,consts:[["role","document"],["dialog",""],[1,"modal-content"]],template:function(i,r){1&i&&(f4(),f(0,"div",0,1)(2,"div",2),ml(3),m()()),2&i&&io("modal-dialog"+(r.size?" modal-"+r.size:"")+(r.centered?" modal-dialog-centered":"")+r.fullscreenClass+(r.scrollable?" modal-dialog-scrollable":"")+(r.modalDialogClass?" "+r.modalDialogClass:""))},styles:["ngb-modal-window .component-host-scrollable{display:flex;flex-direction:column;overflow:hidden}\n"],encapsulation:2})}return t})(),I9e=(()=>{class t{constructor(e){this._document=e}hide(){const e=Math.abs(window.innerWidth-this._document.documentElement.clientWidth),i=this._document.body,r=i.style,{overflow:s,paddingRight:a}=r;if(e>0){const o=parseFloat(window.getComputedStyle(i).paddingRight);r.paddingRight=`${o+e}px`}return r.overflow="hidden",()=>{e>0&&(r.paddingRight=a),r.overflow=s}}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),D9e=(()=>{class t{constructor(e,i,r,s,a,o,c){this._applicationRef=e,this._injector=i,this._environmentInjector=r,this._document=s,this._scrollBar=a,this._rendererFactory=o,this._ngZone=c,this._activeWindowCmptHasChanged=new U,this._ariaHiddenValues=new Map,this._scrollBarRestoreFn=null,this._modalRefs=[],this._windowCmpts=[],this._activeInstances=new Ht,this._activeWindowCmptHasChanged.subscribe(()=>{if(this._windowCmpts.length){const l=this._windowCmpts[this._windowCmpts.length-1];((t,n,e,i=!1)=>{t.runOutsideAngular(()=>{const r=ya(n,"focusin").pipe(yr(e),Le(s=>s.target));ya(n,"keydown").pipe(yr(e),ea(s=>s.which===Nr.Tab),UT(r)).subscribe(([s,a])=>{const[o,c]=RU(n);(a===o||a===n)&&s.shiftKey&&(c.focus(),s.preventDefault()),a===c&&!s.shiftKey&&(o.focus(),s.preventDefault())}),i&&ya(n,"click").pipe(yr(e),UT(r),Le(s=>s[1])).subscribe(s=>s.focus())})})(this._ngZone,l.location.nativeElement,this._activeWindowCmptHasChanged),this._revertAriaHidden(),this._setAriaHidden(l.location.nativeElement)}})}_restoreScrollBar(){const e=this._scrollBarRestoreFn;e&&(this._scrollBarRestoreFn=null,e())}_hideScrollBar(){this._scrollBarRestoreFn||(this._scrollBarRestoreFn=this._scrollBar.hide())}open(e,i,r){const s=r.container instanceof HTMLElement?r.container:T4(r.container)?this._document.querySelector(r.container):this._document.body,a=this._rendererFactory.createRenderer(null,null);if(!s)throw new Error(`The specified modal container "${r.container||"body"}" was not found in the DOM.`);this._hideScrollBar();const o=new ad,c=(e=r.injector||e).get(Ao,null)||this._environmentInjector,l=this._getContentRef(e,c,i,o,r);let u=!1!==r.backdrop?this._attachBackdrop(s):void 0,d=this._attachWindowComponent(s,l.nodes),h=new E9e(d,l,u,r.beforeDismiss);return this._registerModalRef(h),this._registerWindowCmpt(d),h.hidden.pipe(Es(1)).subscribe(()=>Promise.resolve(!0).then(()=>{this._modalRefs.length||(a.removeClass(this._document.body,"modal-open"),this._restoreScrollBar(),this._revertAriaHidden())})),o.close=y=>{h.close(y)},o.dismiss=y=>{h.dismiss(y)},o.update=y=>{h.update(y)},h.update(r),1===this._modalRefs.length&&a.addClass(this._document.body,"modal-open"),u&&u.instance&&u.changeDetectorRef.detectChanges(),d.changeDetectorRef.detectChanges(),h}get activeInstances(){return this._activeInstances}dismissAll(e){this._modalRefs.forEach(i=>i.dismiss(e))}hasOpenModals(){return this._modalRefs.length>0}_attachBackdrop(e){let i=Vx(M9e,{environmentInjector:this._applicationRef.injector,elementInjector:this._injector});return this._applicationRef.attachView(i.hostView),e.appendChild(i.location.nativeElement),i}_attachWindowComponent(e,i){let r=Vx(A9e,{environmentInjector:this._applicationRef.injector,elementInjector:this._injector,projectableNodes:i});return this._applicationRef.attachView(r.hostView),e.appendChild(r.location.nativeElement),r}_getContentRef(e,i,r,s,a){return r?r instanceof sr?this._createFromTemplateRef(r,s):x4(r)?this._createFromString(r):this._createFromComponent(e,i,r,s,a):new A4([])}_createFromTemplateRef(e,i){const s=e.createEmbeddedView({$implicit:i,close(a){i.close(a)},dismiss(a){i.dismiss(a)}});return this._applicationRef.attachView(s),new A4([s.rootNodes],s)}_createFromString(e){const i=this._document.createTextNode(`${e}`);return new A4([[i]])}_createFromComponent(e,i,r,s,a){const c=Vx(r,{environmentInjector:i,elementInjector:ks.create({providers:[{provide:ad,useValue:s}],parent:e})}),l=c.location.nativeElement;return a.scrollable&&l.classList.add("component-host-scrollable"),this._applicationRef.attachView(c.hostView),new A4([[l]],c.hostView,c)}_setAriaHidden(e){const i=e.parentElement;i&&e!==this._document.body&&(Array.from(i.children).forEach(r=>{r!==e&&"SCRIPT"!==r.nodeName&&(this._ariaHiddenValues.set(r,r.getAttribute("aria-hidden")),r.setAttribute("aria-hidden","true"))}),this._setAriaHidden(i))}_revertAriaHidden(){this._ariaHiddenValues.forEach((e,i)=>{e?i.setAttribute("aria-hidden",e):i.removeAttribute("aria-hidden")}),this._ariaHiddenValues.clear()}_registerModalRef(e){const i=()=>{const r=this._modalRefs.indexOf(e);r>-1&&(this._modalRefs.splice(r,1),this._activeInstances.emit(this._modalRefs))};this._modalRefs.push(e),this._activeInstances.emit(this._modalRefs),e.result.then(i,i)}_registerWindowCmpt(e){this._windowCmpts.push(e),this._activeWindowCmptHasChanged.next(),e.onDestroy(()=>{const i=this._windowCmpts.indexOf(e);i>-1&&(this._windowCmpts.splice(i,1),this._activeWindowCmptHasChanged.next())})}static#e=this.\u0275fac=function(i){return new(i||t)(gt(P2),gt(ks),gt(Ao),gt(Pi),gt(I9e),gt(S6),gt(Xn))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),N9e=(()=>{class t{constructor(e){this._ngbConfig=e,this.backdrop=!0,this.fullscreen=!1,this.keyboard=!0}get animation(){return void 0===this._animation?this._ngbConfig.animation:this._animation}set animation(e){this._animation=e}static#e=this.\u0275fac=function(i){return new(i||t)(gt(dg))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),od=(()=>{class t{constructor(e,i,r){this._injector=e,this._modalStack=i,this._config=r}open(e,i={}){const r={...this._config,animation:this._config.animation,...i};return this._modalStack.open(this._injector,e,r)}get activeInstances(){return this._modalStack.activeInstances}dismissAll(e){this._modalStack.dismissAll(e)}hasOpenModals(){return this._modalStack.hasOpenModals()}static#e=this.\u0275fac=function(i){return new(i||t)(gt(ks),gt(D9e),gt(N9e))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),KU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({providers:[od]})}return t})(),JU=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),o$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),c$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),l$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),u$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),d$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),f$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),h$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),p$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();new Jt("live announcer delay",{providedIn:"root",factory:function G9e(){return 100}});let m$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})(),g$=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();const Y9e=[bU,wU,TU,MU,qU,YU,KU,JU,g$,o$,c$,l$,u$,d$,f$,h$,p$,m$];let K9e=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({imports:[Y9e,bU,wU,TU,MU,qU,YU,KU,JU,g$,o$,c$,l$,u$,d$,f$,h$,p$,m$]})}return t})();class v${}class X9e{}const wl="*";function wc(t,n){return{type:7,name:t,definitions:n,options:{}}}function Vo(t,n=null){return{type:4,styles:n,timings:t}}function y$(t,n=null){return{type:2,steps:t,options:n}}function lr(t){return{type:6,styles:t,offset:null}}function oo(t,n,e){return{type:0,name:t,styles:n,options:e}}function Tg(t){return{type:5,steps:t}}function co(t,n,e=null){return{type:1,expr:t,animation:n,options:e}}function Q9e(t=null){return{type:9,options:t}}function J9e(t,n,e=null){return{type:11,selector:t,animation:n,options:e}}class M8{constructor(n=0,e=0){this._onDoneFns=[],this._onStartFns=[],this._onDestroyFns=[],this._originalOnDoneFns=[],this._originalOnStartFns=[],this._started=!1,this._destroyed=!1,this._finished=!1,this._position=0,this.parentPlayer=null,this.totalTime=n+e}_onFinish(){this._finished||(this._finished=!0,this._onDoneFns.forEach(n=>n()),this._onDoneFns=[])}onStart(n){this._originalOnStartFns.push(n),this._onStartFns.push(n)}onDone(n){this._originalOnDoneFns.push(n),this._onDoneFns.push(n)}onDestroy(n){this._onDestroyFns.push(n)}hasStarted(){return this._started}init(){}play(){this.hasStarted()||(this._onStart(),this.triggerMicrotask()),this._started=!0}triggerMicrotask(){queueMicrotask(()=>this._onFinish())}_onStart(){this._onStartFns.forEach(n=>n()),this._onStartFns=[]}pause(){}restart(){}finish(){this._onFinish()}destroy(){this._destroyed||(this._destroyed=!0,this.hasStarted()||this._onStart(),this.finish(),this._onDestroyFns.forEach(n=>n()),this._onDestroyFns=[])}reset(){this._started=!1,this._finished=!1,this._onStartFns=this._originalOnStartFns,this._onDoneFns=this._originalOnDoneFns}setPosition(n){this._position=this.totalTime?n*this.totalTime:1}getPosition(){return this.totalTime?this._position/this.totalTime:1}triggerCallback(n){const e="start"==n?this._onStartFns:this._onDoneFns;e.forEach(i=>i()),e.length=0}}class _${constructor(n){this._onDoneFns=[],this._onStartFns=[],this._finished=!1,this._started=!1,this._destroyed=!1,this._onDestroyFns=[],this.parentPlayer=null,this.totalTime=0,this.players=n;let e=0,i=0,r=0;const s=this.players.length;0==s?queueMicrotask(()=>this._onFinish()):this.players.forEach(a=>{a.onDone(()=>{++e==s&&this._onFinish()}),a.onDestroy(()=>{++i==s&&this._onDestroy()}),a.onStart(()=>{++r==s&&this._onStart()})}),this.totalTime=this.players.reduce((a,o)=>Math.max(a,o.totalTime),0)}_onFinish(){this._finished||(this._finished=!0,this._onDoneFns.forEach(n=>n()),this._onDoneFns=[])}init(){this.players.forEach(n=>n.init())}onStart(n){this._onStartFns.push(n)}_onStart(){this.hasStarted()||(this._started=!0,this._onStartFns.forEach(n=>n()),this._onStartFns=[])}onDone(n){this._onDoneFns.push(n)}onDestroy(n){this._onDestroyFns.push(n)}hasStarted(){return this._started}play(){this.parentPlayer||this.init(),this._onStart(),this.players.forEach(n=>n.play())}pause(){this.players.forEach(n=>n.pause())}restart(){this.players.forEach(n=>n.restart())}finish(){this._onFinish(),this.players.forEach(n=>n.finish())}destroy(){this._onDestroy()}_onDestroy(){this._destroyed||(this._destroyed=!0,this._onFinish(),this.players.forEach(n=>n.destroy()),this._onDestroyFns.forEach(n=>n()),this._onDestroyFns=[])}reset(){this.players.forEach(n=>n.reset()),this._destroyed=!1,this._finished=!1,this._started=!1}setPosition(n){const e=n*this.totalTime;this.players.forEach(i=>{const r=i.totalTime?Math.min(1,e/i.totalTime):1;i.setPosition(r)})}getPosition(){const n=this.players.reduce((e,i)=>null===e||i.totalTime>e.totalTime?i:e,null);return null!=n?n.getPosition():0}beforeDestroy(){this.players.forEach(n=>{n.beforeDestroy&&n.beforeDestroy()})}triggerCallback(n){const e="start"==n?this._onStartFns:this._onDoneFns;e.forEach(i=>i()),e.length=0}}function b$(t){return new kt(3e3,!1)}function O3(t){switch(t.length){case 0:return new M8;case 1:return t[0];default:return new _$(t)}}function w$(t,n,e=new Map,i=new Map){const r=[],s=[];let a=-1,o=null;if(n.forEach(c=>{const l=c.get("offset"),u=l==a,d=u&&o||new Map;c.forEach((h,y)=>{let I=y,D=h;if("offset"!==y)switch(I=t.normalizePropertyName(I,r),D){case"!":D=e.get(y);break;case wl:D=i.get(y);break;default:D=t.normalizeStyleValue(y,I,D,r)}d.set(I,D)}),u||s.push(d),o=d,a=l}),r.length)throw function Cge(t){return new kt(3502,!1)}();return s}function wM(t,n,e,i){switch(n){case"start":t.onStart(()=>i(e&&CM(e,"start",t)));break;case"done":t.onDone(()=>i(e&&CM(e,"done",t)));break;case"destroy":t.onDestroy(()=>i(e&&CM(e,"destroy",t)))}}function CM(t,n,e){const s=xM(t.element,t.triggerName,t.fromState,t.toState,n||t.phaseName,e.totalTime??t.totalTime,!!e.disabled),a=t._data;return null!=a&&(s._data=a),s}function xM(t,n,e,i,r="",s=0,a){return{element:t,triggerName:n,fromState:e,toState:i,phaseName:r,totalTime:s,disabled:!!a}}function T1(t,n,e){let i=t.get(n);return i||t.set(n,i=e),i}function C$(t){const n=t.indexOf(":");return[t.substring(1,n),t.slice(n+1)]}const Lge=(()=>typeof document>"u"?null:document.documentElement)();function TM(t){const n=t.parentNode||t.host||null;return n===Lge?null:n}let I4=null,x$=!1;function T$(t,n){for(;n;){if(n===t)return!0;n=TM(n)}return!1}function M$(t,n,e){if(e)return Array.from(t.querySelectorAll(n));const i=t.querySelector(n);return i?[i]:[]}let k$=(()=>{class t{validateStyleProperty(e){return function zge(t){I4||(I4=function Oge(){return typeof document<"u"?document.body:null}()||{},x$=!!I4.style&&"WebkitAppearance"in I4.style);let n=!0;return I4.style&&!function Pge(t){return"ebkit"==t.substring(1,6)}(t)&&(n=t in I4.style,!n&&x$&&(n="Webkit"+t.charAt(0).toUpperCase()+t.slice(1)in I4.style)),n}(e)}matchesElement(e,i){return!1}containsElement(e,i){return T$(e,i)}getParentElement(e){return TM(e)}query(e,i,r){return M$(e,i,r)}computeStyle(e,i,r){return r||""}animate(e,i,r,s,a,o=[],c){return new M8(r,s)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})(),MM=(()=>{class t{static#e=this.NOOP=new k$}return t})();const Hge=1e3,kM="ng-enter",Mg="ng-leave",kg="ng-trigger",Sg=".ng-trigger",E$="ng-animating",SM=".ng-animating";function Cl(t){if("number"==typeof t)return t;const n=t.match(/^(-?[\.\d]+)(m?s)/);return!n||n.length<2?0:EM(parseFloat(n[1]),n[2])}function EM(t,n){return"s"===n?t*Hge:t}function Eg(t,n,e){return t.hasOwnProperty("duration")?t:function Fge(t,n,e){let r,s=0,a="";if("string"==typeof t){const o=t.match(/^(-?[\.\d]+)(m?s)(?:\s+(-?[\.\d]+)(m?s))?(?:\s+([-a-z]+(?:\(.+?\))?))?$/i);if(null===o)return n.push(b$()),{duration:0,delay:0,easing:""};r=EM(parseFloat(o[1]),o[2]);const c=o[3];null!=c&&(s=EM(parseFloat(c),o[4]));const l=o[5];l&&(a=l)}else r=t;if(!e){let o=!1,c=n.length;r<0&&(n.push(function ege(){return new kt(3100,!1)}()),o=!0),s<0&&(n.push(function tge(){return new kt(3101,!1)}()),o=!0),o&&n.splice(c,0,b$())}return{duration:r,delay:s,easing:a}}(t,n,e)}function k8(t,n={}){return Object.keys(t).forEach(e=>{n[e]=t[e]}),n}function A$(t){const n=new Map;return Object.keys(t).forEach(e=>{n.set(e,t[e])}),n}function H3(t,n=new Map,e){if(e)for(let[i,r]of e)n.set(i,r);for(let[i,r]of t)n.set(i,r);return n}function Cc(t,n,e){n.forEach((i,r)=>{const s=IM(r);e&&!e.has(r)&&e.set(r,t.style[s]),t.style[s]=i})}function D4(t,n){n.forEach((e,i)=>{const r=IM(i);t.style[r]=""})}function S8(t){return Array.isArray(t)?1==t.length?t[0]:y$(t):t}const AM=new RegExp("{{\\s*(.+?)\\s*}}","g");function D$(t){let n=[];if("string"==typeof t){let e;for(;e=AM.exec(t);)n.push(e[1]);AM.lastIndex=0}return n}function E8(t,n,e){const i=t.toString(),r=i.replace(AM,(s,a)=>{let o=n[a];return null==o&&(e.push(function ige(t){return new kt(3003,!1)}()),o=""),o.toString()});return r==i?t:r}function Ag(t){const n=[];let e=t.next();for(;!e.done;)n.push(e.value),e=t.next();return n}const $ge=/-+([a-z0-9])/g;function IM(t){return t.replace($ge,(...n)=>n[1].toUpperCase())}function M1(t,n,e){switch(n.type){case 7:return t.visitTrigger(n,e);case 0:return t.visitState(n,e);case 1:return t.visitTransition(n,e);case 2:return t.visitSequence(n,e);case 3:return t.visitGroup(n,e);case 4:return t.visitAnimate(n,e);case 5:return t.visitKeyframes(n,e);case 6:return t.visitStyle(n,e);case 8:return t.visitReference(n,e);case 9:return t.visitAnimateChild(n,e);case 10:return t.visitAnimateRef(n,e);case 11:return t.visitQuery(n,e);case 12:return t.visitStagger(n,e);default:throw function rge(t){return new kt(3004,!1)}()}}function N$(t,n){return window.getComputedStyle(t)[n]}const Ig="*";function qge(t,n){const e=[];return"string"==typeof t?t.split(/\s*,\s*/).forEach(i=>function Gge(t,n,e){if(":"==t[0]){const c=function Zge(t,n){switch(t){case":enter":return"void => *";case":leave":return"* => void";case":increment":return(e,i)=>parseFloat(i)>parseFloat(e);case":decrement":return(e,i)=>parseFloat(i)<parseFloat(e);default:return n.push(function yge(t){return new kt(3016,!1)}()),"* => *"}}(t,e);if("function"==typeof c)return void n.push(c);t=c}const i=t.match(/^(\*|[-\w]+)\s*(<?[=-]>)\s*(\*|[-\w]+)$/);if(null==i||i.length<4)return e.push(function vge(t){return new kt(3015,!1)}()),n;const r=i[1],s=i[2],a=i[3];n.push(R$(r,a));"<"==s[0]&&!(r==Ig&&a==Ig)&&n.push(R$(a,r))}(i,e,n)):e.push(t),e}const Dg=new Set(["true","1"]),Ng=new Set(["false","0"]);function R$(t,n){const e=Dg.has(t)||Ng.has(t),i=Dg.has(n)||Ng.has(n);return(r,s)=>{let a=t==Ig||t==r,o=n==Ig||n==s;return!a&&e&&"boolean"==typeof r&&(a=r?Dg.has(t):Ng.has(t)),!o&&i&&"boolean"==typeof s&&(o=s?Dg.has(n):Ng.has(n)),a&&o}}const Yge=new RegExp("s*:selfs*,?","g");function DM(t,n,e,i){return new Kge(t).build(n,e,i)}class Kge{constructor(n){this._driver=n}build(n,e,i){const r=new Jge(e);return this._resetContextStyleTimingState(r),M1(this,S8(n),r)}_resetContextStyleTimingState(n){n.currentQuerySelector="",n.collectedStyles=new Map,n.collectedStyles.set("",new Map),n.currentTime=0}visitTrigger(n,e){let i=e.queryCount=0,r=e.depCount=0;const s=[],a=[];return"@"==n.name.charAt(0)&&e.errors.push(function age(){return new kt(3006,!1)}()),n.definitions.forEach(o=>{if(this._resetContextStyleTimingState(e),0==o.type){const c=o,l=c.name;l.toString().split(/\s*,\s*/).forEach(u=>{c.name=u,s.push(this.visitState(c,e))}),c.name=l}else if(1==o.type){const c=this.visitTransition(o,e);i+=c.queryCount,r+=c.depCount,a.push(c)}else e.errors.push(function oge(){return new kt(3007,!1)}())}),{type:7,name:n.name,states:s,transitions:a,queryCount:i,depCount:r,options:null}}visitState(n,e){const i=this.visitStyle(n.styles,e),r=n.options&&n.options.params||null;if(i.containsDynamicStyles){const s=new Set,a=r||{};i.styles.forEach(o=>{o instanceof Map&&o.forEach(c=>{D$(c).forEach(l=>{a.hasOwnProperty(l)||s.add(l)})})}),s.size&&(Ag(s.values()),e.errors.push(function cge(t,n){return new kt(3008,!1)}()))}return{type:0,name:n.name,style:i,options:r?{params:r}:null}}visitTransition(n,e){e.queryCount=0,e.depCount=0;const i=M1(this,S8(n.animation),e);return{type:1,matchers:qge(n.expr,e.errors),animation:i,queryCount:e.queryCount,depCount:e.depCount,options:N4(n.options)}}visitSequence(n,e){return{type:2,steps:n.steps.map(i=>M1(this,i,e)),options:N4(n.options)}}visitGroup(n,e){const i=e.currentTime;let r=0;const s=n.steps.map(a=>{e.currentTime=i;const o=M1(this,a,e);return r=Math.max(r,e.currentTime),o});return e.currentTime=r,{type:3,steps:s,options:N4(n.options)}}visitAnimate(n,e){const i=function tve(t,n){if(t.hasOwnProperty("duration"))return t;if("number"==typeof t)return NM(Eg(t,n).duration,0,"");const e=t;if(e.split(/\s+/).some(s=>"{"==s.charAt(0)&&"{"==s.charAt(1))){const s=NM(0,0,"");return s.dynamic=!0,s.strValue=e,s}const r=Eg(e,n);return NM(r.duration,r.delay,r.easing)}(n.timings,e.errors);e.currentAnimateTimings=i;let r,s=n.styles?n.styles:lr({});if(5==s.type)r=this.visitKeyframes(s,e);else{let a=n.styles,o=!1;if(!a){o=!0;const l={};i.easing&&(l.easing=i.easing),a=lr(l)}e.currentTime+=i.duration+i.delay;const c=this.visitStyle(a,e);c.isEmptyStep=o,r=c}return e.currentAnimateTimings=null,{type:4,timings:i,style:r,options:null}}visitStyle(n,e){const i=this._makeStyleAst(n,e);return this._validateStyleAst(i,e),i}_makeStyleAst(n,e){const i=[],r=Array.isArray(n.styles)?n.styles:[n.styles];for(let o of r)"string"==typeof o?o===wl?i.push(o):e.errors.push(new kt(3002,!1)):i.push(A$(o));let s=!1,a=null;return i.forEach(o=>{if(o instanceof Map&&(o.has("easing")&&(a=o.get("easing"),o.delete("easing")),!s))for(let c of o.values())if(c.toString().indexOf("{{")>=0){s=!0;break}}),{type:6,styles:i,easing:a,offset:n.offset,containsDynamicStyles:s,options:null}}_validateStyleAst(n,e){const i=e.currentAnimateTimings;let r=e.currentTime,s=e.currentTime;i&&s>0&&(s-=i.duration+i.delay),n.styles.forEach(a=>{"string"!=typeof a&&a.forEach((o,c)=>{const l=e.collectedStyles.get(e.currentQuerySelector),u=l.get(c);let d=!0;u&&(s!=r&&s>=u.startTime&&r<=u.endTime&&(e.errors.push(function uge(t,n,e,i,r){return new kt(3010,!1)}()),d=!1),s=u.startTime),d&&l.set(c,{startTime:s,endTime:r}),e.options&&function Uge(t,n,e){const i=n.params||{},r=D$(t);r.length&&r.forEach(s=>{i.hasOwnProperty(s)||e.push(function nge(t){return new kt(3001,!1)}())})}(o,e.options,e.errors)})})}visitKeyframes(n,e){const i={type:5,styles:[],options:null};if(!e.currentAnimateTimings)return e.errors.push(function dge(){return new kt(3011,!1)}()),i;let s=0;const a=[];let o=!1,c=!1,l=0;const u=n.steps.map(we=>{const Ce=this._makeStyleAst(we,e);let Ve=null!=Ce.offset?Ce.offset:function eve(t){if("string"==typeof t)return null;let n=null;if(Array.isArray(t))t.forEach(e=>{if(e instanceof Map&&e.has("offset")){const i=e;n=parseFloat(i.get("offset")),i.delete("offset")}});else if(t instanceof Map&&t.has("offset")){const e=t;n=parseFloat(e.get("offset")),e.delete("offset")}return n}(Ce.styles),Fe=0;return null!=Ve&&(s++,Fe=Ce.offset=Ve),c=c||Fe<0||Fe>1,o=o||Fe<l,l=Fe,a.push(Fe),Ce});c&&e.errors.push(function fge(){return new kt(3012,!1)}()),o&&e.errors.push(function hge(){return new kt(3200,!1)}());const d=n.steps.length;let h=0;s>0&&s<d?e.errors.push(function pge(){return new kt(3202,!1)}()):0==s&&(h=1/(d-1));const y=d-1,I=e.currentTime,D=e.currentAnimateTimings,V=D.duration;return u.forEach((we,Ce)=>{const Ve=h>0?Ce==y?1:h*Ce:a[Ce],Fe=Ve*V;e.currentTime=I+D.delay+Fe,D.duration=Fe,this._validateStyleAst(we,e),we.offset=Ve,i.styles.push(we)}),i}visitReference(n,e){return{type:8,animation:M1(this,S8(n.animation),e),options:N4(n.options)}}visitAnimateChild(n,e){return e.depCount++,{type:9,options:N4(n.options)}}visitAnimateRef(n,e){return{type:10,animation:this.visitReference(n.animation,e),options:N4(n.options)}}visitQuery(n,e){const i=e.currentQuerySelector,r=n.options||{};e.queryCount++,e.currentQuery=n;const[s,a]=function Xge(t){const n=!!t.split(/\s*,\s*/).find(e=>":self"==e);return n&&(t=t.replace(Yge,"")),t=t.replace(/@\*/g,Sg).replace(/@\w+/g,e=>Sg+"-"+e.slice(1)).replace(/:animating/g,SM),[t,n]}(n.selector);e.currentQuerySelector=i.length?i+" "+s:s,T1(e.collectedStyles,e.currentQuerySelector,new Map);const o=M1(this,S8(n.animation),e);return e.currentQuery=null,e.currentQuerySelector=i,{type:11,selector:s,limit:r.limit||0,optional:!!r.optional,includeSelf:a,animation:o,originalSelector:n.selector,options:N4(n.options)}}visitStagger(n,e){e.currentQuery||e.errors.push(function mge(){return new kt(3013,!1)}());const i="full"===n.timings?{duration:0,delay:0,easing:"full"}:Eg(n.timings,e.errors,!0);return{type:12,animation:M1(this,S8(n.animation),e),timings:i,options:null}}}class Jge{constructor(n){this.errors=n,this.queryCount=0,this.depCount=0,this.currentTransition=null,this.currentQuery=null,this.currentQuerySelector=null,this.currentAnimateTimings=null,this.currentTime=0,this.collectedStyles=new Map,this.options=null,this.unsupportedCSSPropertiesFound=new Set}}function N4(t){return t?(t=k8(t)).params&&(t.params=function Qge(t){return t?k8(t):null}(t.params)):t={},t}function NM(t,n,e){return{duration:t,delay:n,easing:e}}function RM(t,n,e,i,r,s,a=null,o=!1){return{type:1,element:t,keyframes:n,preStyleProps:e,postStyleProps:i,duration:r,delay:s,totalTime:r+s,easing:a,subTimeline:o}}class Rg{constructor(){this._map=new Map}get(n){return this._map.get(n)||[]}append(n,e){let i=this._map.get(n);i||this._map.set(n,i=[]),i.push(...e)}has(n){return this._map.has(n)}clear(){this._map.clear()}}const rve=new RegExp(":enter","g"),ave=new RegExp(":leave","g");function LM(t,n,e,i,r,s=new Map,a=new Map,o,c,l=[]){return(new ove).buildKeyframes(t,n,e,i,r,s,a,o,c,l)}class ove{buildKeyframes(n,e,i,r,s,a,o,c,l,u=[]){l=l||new Rg;const d=new PM(n,e,l,r,s,u,[]);d.options=c;const h=c.delay?Cl(c.delay):0;d.currentTimeline.delayNextStep(h),d.currentTimeline.setStyles([a],null,d.errors,c),M1(this,i,d);const y=d.timelines.filter(I=>I.containsAnimation());if(y.length&&o.size){let I;for(let D=y.length-1;D>=0;D--){const V=y[D];if(V.element===e){I=V;break}}I&&!I.allowOnlyTimelineStyles()&&I.setStyles([o],null,d.errors,c)}return y.length?y.map(I=>I.buildKeyframes()):[RM(e,[],[],[],0,h,"",!1)]}visitTrigger(n,e){}visitState(n,e){}visitTransition(n,e){}visitAnimateChild(n,e){const i=e.subInstructions.get(e.element);if(i){const r=e.createSubContext(n.options),s=e.currentTimeline.currentTime,a=this._visitSubInstructions(i,r,r.options);s!=a&&e.transformIntoNewTimeline(a)}e.previousNode=n}visitAnimateRef(n,e){const i=e.createSubContext(n.options);i.transformIntoNewTimeline(),this._applyAnimationRefDelays([n.options,n.animation.options],e,i),this.visitReference(n.animation,i),e.transformIntoNewTimeline(i.currentTimeline.currentTime),e.previousNode=n}_applyAnimationRefDelays(n,e,i){for(const r of n){const s=r?.delay;if(s){const a="number"==typeof s?s:Cl(E8(s,r?.params??{},e.errors));i.delayNextStep(a)}}}_visitSubInstructions(n,e,i){let s=e.currentTimeline.currentTime;const a=null!=i.duration?Cl(i.duration):null,o=null!=i.delay?Cl(i.delay):null;return 0!==a&&n.forEach(c=>{const l=e.appendInstructionToTimeline(c,a,o);s=Math.max(s,l.duration+l.delay)}),s}visitReference(n,e){e.updateOptions(n.options,!0),M1(this,n.animation,e),e.previousNode=n}visitSequence(n,e){const i=e.subContextCount;let r=e;const s=n.options;if(s&&(s.params||s.delay)&&(r=e.createSubContext(s),r.transformIntoNewTimeline(),null!=s.delay)){6==r.previousNode.type&&(r.currentTimeline.snapshotCurrentStyles(),r.previousNode=Lg);const a=Cl(s.delay);r.delayNextStep(a)}n.steps.length&&(n.steps.forEach(a=>M1(this,a,r)),r.currentTimeline.applyStylesToKeyframe(),r.subContextCount>i&&r.transformIntoNewTimeline()),e.previousNode=n}visitGroup(n,e){const i=[];let r=e.currentTimeline.currentTime;const s=n.options&&n.options.delay?Cl(n.options.delay):0;n.steps.forEach(a=>{const o=e.createSubContext(n.options);s&&o.delayNextStep(s),M1(this,a,o),r=Math.max(r,o.currentTimeline.currentTime),i.push(o.currentTimeline)}),i.forEach(a=>e.currentTimeline.mergeTimelineCollectedStyles(a)),e.transformIntoNewTimeline(r),e.previousNode=n}_visitTiming(n,e){if(n.dynamic){const i=n.strValue;return Eg(e.params?E8(i,e.params,e.errors):i,e.errors)}return{duration:n.duration,delay:n.delay,easing:n.easing}}visitAnimate(n,e){const i=e.currentAnimateTimings=this._visitTiming(n.timings,e),r=e.currentTimeline;i.delay&&(e.incrementTime(i.delay),r.snapshotCurrentStyles());const s=n.style;5==s.type?this.visitKeyframes(s,e):(e.incrementTime(i.duration),this.visitStyle(s,e),r.applyStylesToKeyframe()),e.currentAnimateTimings=null,e.previousNode=n}visitStyle(n,e){const i=e.currentTimeline,r=e.currentAnimateTimings;!r&&i.hasCurrentStyleProperties()&&i.forwardFrame();const s=r&&r.easing||n.easing;n.isEmptyStep?i.applyEmptyStep(s):i.setStyles(n.styles,s,e.errors,e.options),e.previousNode=n}visitKeyframes(n,e){const i=e.currentAnimateTimings,r=e.currentTimeline.duration,s=i.duration,o=e.createSubContext().currentTimeline;o.easing=i.easing,n.styles.forEach(c=>{o.forwardTime((c.offset||0)*s),o.setStyles(c.styles,c.easing,e.errors,e.options),o.applyStylesToKeyframe()}),e.currentTimeline.mergeTimelineCollectedStyles(o),e.transformIntoNewTimeline(r+s),e.previousNode=n}visitQuery(n,e){const i=e.currentTimeline.currentTime,r=n.options||{},s=r.delay?Cl(r.delay):0;s&&(6===e.previousNode.type||0==i&&e.currentTimeline.hasCurrentStyleProperties())&&(e.currentTimeline.snapshotCurrentStyles(),e.previousNode=Lg);let a=i;const o=e.invokeQuery(n.selector,n.originalSelector,n.limit,n.includeSelf,!!r.optional,e.errors);e.currentQueryTotal=o.length;let c=null;o.forEach((l,u)=>{e.currentQueryIndex=u;const d=e.createSubContext(n.options,l);s&&d.delayNextStep(s),l===e.element&&(c=d.currentTimeline),M1(this,n.animation,d),d.currentTimeline.applyStylesToKeyframe(),a=Math.max(a,d.currentTimeline.currentTime)}),e.currentQueryIndex=0,e.currentQueryTotal=0,e.transformIntoNewTimeline(a),c&&(e.currentTimeline.mergeTimelineCollectedStyles(c),e.currentTimeline.snapshotCurrentStyles()),e.previousNode=n}visitStagger(n,e){const i=e.parentContext,r=e.currentTimeline,s=n.timings,a=Math.abs(s.duration),o=a*(e.currentQueryTotal-1);let c=a*e.currentQueryIndex;switch(s.duration<0?"reverse":s.easing){case"reverse":c=o-c;break;case"full":c=i.currentStaggerTime}const u=e.currentTimeline;c&&u.delayNextStep(c);const d=u.currentTime;M1(this,n.animation,e),e.previousNode=n,i.currentStaggerTime=r.currentTime-d+(r.startTime-i.currentTimeline.startTime)}}const Lg={};class PM{constructor(n,e,i,r,s,a,o,c){this._driver=n,this.element=e,this.subInstructions=i,this._enterClassName=r,this._leaveClassName=s,this.errors=a,this.timelines=o,this.parentContext=null,this.currentAnimateTimings=null,this.previousNode=Lg,this.subContextCount=0,this.options={},this.currentQueryIndex=0,this.currentQueryTotal=0,this.currentStaggerTime=0,this.currentTimeline=c||new Pg(this._driver,e,0),o.push(this.currentTimeline)}get params(){return this.options.params}updateOptions(n,e){if(!n)return;const i=n;let r=this.options;null!=i.duration&&(r.duration=Cl(i.duration)),null!=i.delay&&(r.delay=Cl(i.delay));const s=i.params;if(s){let a=r.params;a||(a=this.options.params={}),Object.keys(s).forEach(o=>{(!e||!a.hasOwnProperty(o))&&(a[o]=E8(s[o],a,this.errors))})}}_copyOptions(){const n={};if(this.options){const e=this.options.params;if(e){const i=n.params={};Object.keys(e).forEach(r=>{i[r]=e[r]})}}return n}createSubContext(n=null,e,i){const r=e||this.element,s=new PM(this._driver,r,this.subInstructions,this._enterClassName,this._leaveClassName,this.errors,this.timelines,this.currentTimeline.fork(r,i||0));return s.previousNode=this.previousNode,s.currentAnimateTimings=this.currentAnimateTimings,s.options=this._copyOptions(),s.updateOptions(n),s.currentQueryIndex=this.currentQueryIndex,s.currentQueryTotal=this.currentQueryTotal,s.parentContext=this,this.subContextCount++,s}transformIntoNewTimeline(n){return this.previousNode=Lg,this.currentTimeline=this.currentTimeline.fork(this.element,n),this.timelines.push(this.currentTimeline),this.currentTimeline}appendInstructionToTimeline(n,e,i){const r={duration:e??n.duration,delay:this.currentTimeline.currentTime+(i??0)+n.delay,easing:""},s=new cve(this._driver,n.element,n.keyframes,n.preStyleProps,n.postStyleProps,r,n.stretchStartingKeyframe);return this.timelines.push(s),r}incrementTime(n){this.currentTimeline.forwardTime(this.currentTimeline.duration+n)}delayNextStep(n){n>0&&this.currentTimeline.delayNextStep(n)}invokeQuery(n,e,i,r,s,a){let o=[];if(r&&o.push(this.element),n.length>0){n=(n=n.replace(rve,"."+this._enterClassName)).replace(ave,"."+this._leaveClassName);let l=this._driver.query(this.element,n,1!=i);0!==i&&(l=i<0?l.slice(l.length+i,l.length):l.slice(0,i)),o.push(...l)}return!s&&0==o.length&&a.push(function gge(t){return new kt(3014,!1)}()),o}}class Pg{constructor(n,e,i,r){this._driver=n,this.element=e,this.startTime=i,this._elementTimelineStylesLookup=r,this.duration=0,this.easing=null,this._previousKeyframe=new Map,this._currentKeyframe=new Map,this._keyframes=new Map,this._styleSummary=new Map,this._localTimelineStyles=new Map,this._pendingStyles=new Map,this._backFill=new Map,this._currentEmptyStepKeyframe=null,this._elementTimelineStylesLookup||(this._elementTimelineStylesLookup=new Map),this._globalTimelineStyles=this._elementTimelineStylesLookup.get(e),this._globalTimelineStyles||(this._globalTimelineStyles=this._localTimelineStyles,this._elementTimelineStylesLookup.set(e,this._localTimelineStyles)),this._loadKeyframe()}containsAnimation(){switch(this._keyframes.size){case 0:return!1;case 1:return this.hasCurrentStyleProperties();default:return!0}}hasCurrentStyleProperties(){return this._currentKeyframe.size>0}get currentTime(){return this.startTime+this.duration}delayNextStep(n){const e=1===this._keyframes.size&&this._pendingStyles.size;this.duration||e?(this.forwardTime(this.currentTime+n),e&&this.snapshotCurrentStyles()):this.startTime+=n}fork(n,e){return this.applyStylesToKeyframe(),new Pg(this._driver,n,e||this.currentTime,this._elementTimelineStylesLookup)}_loadKeyframe(){this._currentKeyframe&&(this._previousKeyframe=this._currentKeyframe),this._currentKeyframe=this._keyframes.get(this.duration),this._currentKeyframe||(this._currentKeyframe=new Map,this._keyframes.set(this.duration,this._currentKeyframe))}forwardFrame(){this.duration+=1,this._loadKeyframe()}forwardTime(n){this.applyStylesToKeyframe(),this.duration=n,this._loadKeyframe()}_updateStyle(n,e){this._localTimelineStyles.set(n,e),this._globalTimelineStyles.set(n,e),this._styleSummary.set(n,{time:this.currentTime,value:e})}allowOnlyTimelineStyles(){return this._currentEmptyStepKeyframe!==this._currentKeyframe}applyEmptyStep(n){n&&this._previousKeyframe.set("easing",n);for(let[e,i]of this._globalTimelineStyles)this._backFill.set(e,i||wl),this._currentKeyframe.set(e,wl);this._currentEmptyStepKeyframe=this._currentKeyframe}setStyles(n,e,i,r){e&&this._previousKeyframe.set("easing",e);const s=r&&r.params||{},a=function lve(t,n){const e=new Map;let i;return t.forEach(r=>{if("*"===r){i=i||n.keys();for(let s of i)e.set(s,wl)}else H3(r,e)}),e}(n,this._globalTimelineStyles);for(let[o,c]of a){const l=E8(c,s,i);this._pendingStyles.set(o,l),this._localTimelineStyles.has(o)||this._backFill.set(o,this._globalTimelineStyles.get(o)??wl),this._updateStyle(o,l)}}applyStylesToKeyframe(){0!=this._pendingStyles.size&&(this._pendingStyles.forEach((n,e)=>{this._currentKeyframe.set(e,n)}),this._pendingStyles.clear(),this._localTimelineStyles.forEach((n,e)=>{this._currentKeyframe.has(e)||this._currentKeyframe.set(e,n)}))}snapshotCurrentStyles(){for(let[n,e]of this._localTimelineStyles)this._pendingStyles.set(n,e),this._updateStyle(n,e)}getFinalKeyframe(){return this._keyframes.get(this.duration)}get properties(){const n=[];for(let e in this._currentKeyframe)n.push(e);return n}mergeTimelineCollectedStyles(n){n._styleSummary.forEach((e,i)=>{const r=this._styleSummary.get(i);(!r||e.time>r.time)&&this._updateStyle(i,e.value)})}buildKeyframes(){this.applyStylesToKeyframe();const n=new Set,e=new Set,i=1===this._keyframes.size&&0===this.duration;let r=[];this._keyframes.forEach((o,c)=>{const l=H3(o,new Map,this._backFill);l.forEach((u,d)=>{"!"===u?n.add(d):u===wl&&e.add(d)}),i||l.set("offset",c/this.duration),r.push(l)});const s=n.size?Ag(n.values()):[],a=e.size?Ag(e.values()):[];if(i){const o=r[0],c=new Map(o);o.set("offset",0),c.set("offset",1),r=[o,c]}return RM(this.element,r,s,a,this.duration,this.startTime,this.easing,!1)}}class cve extends Pg{constructor(n,e,i,r,s,a,o=!1){super(n,e,a.delay),this.keyframes=i,this.preStyleProps=r,this.postStyleProps=s,this._stretchStartingKeyframe=o,this.timings={duration:a.duration,delay:a.delay,easing:a.easing}}containsAnimation(){return this.keyframes.length>1}buildKeyframes(){let n=this.keyframes,{delay:e,duration:i,easing:r}=this.timings;if(this._stretchStartingKeyframe&&e){const s=[],a=i+e,o=e/a,c=H3(n[0]);c.set("offset",0),s.push(c);const l=H3(n[0]);l.set("offset",z$(o)),s.push(l);const u=n.length-1;for(let d=1;d<=u;d++){let h=H3(n[d]);const y=h.get("offset");h.set("offset",z$((e+y*i)/a)),s.push(h)}i=a,e=0,r="",n=s}return RM(this.element,n,this.preStyleProps,this.postStyleProps,i,e,r,!0)}}function z$(t,n=3){const e=Math.pow(10,n-1);return Math.round(t*e)/e}class zM{}const uve=new Set(["width","height","minWidth","minHeight","maxWidth","maxHeight","left","top","bottom","right","fontSize","outlineWidth","outlineOffset","paddingTop","paddingLeft","paddingBottom","paddingRight","marginTop","marginLeft","marginBottom","marginRight","borderRadius","borderWidth","borderTopWidth","borderLeftWidth","borderRightWidth","borderBottomWidth","textIndent","perspective"]);class dve extends zM{normalizePropertyName(n,e){return IM(n)}normalizeStyleValue(n,e,i,r){let s="";const a=i.toString().trim();if(uve.has(e)&&0!==i&&"0"!==i)if("number"==typeof i)s="px";else{const o=i.match(/^[+-]?[\d\.]+([a-z]*)$/);o&&0==o[1].length&&r.push(function sge(t,n){return new kt(3005,!1)}())}return a+s}}function O$(t,n,e,i,r,s,a,o,c,l,u,d,h){return{type:0,element:t,triggerName:n,isRemovalTransition:r,fromState:e,fromStyles:s,toState:i,toStyles:a,timelines:o,queriedElements:c,preStyleProps:l,postStyleProps:u,totalTime:d,errors:h}}const OM={};class H${constructor(n,e,i){this._triggerName=n,this.ast=e,this._stateStyles=i}match(n,e,i,r){return function fve(t,n,e,i,r){return t.some(s=>s(n,e,i,r))}(this.ast.matchers,n,e,i,r)}buildStyles(n,e,i){let r=this._stateStyles.get("*");return void 0!==n&&(r=this._stateStyles.get(n?.toString())||r),r?r.buildStyles(e,i):new Map}build(n,e,i,r,s,a,o,c,l,u){const d=[],h=this.ast.options&&this.ast.options.params||OM,I=this.buildStyles(i,o&&o.params||OM,d),D=c&&c.params||OM,V=this.buildStyles(r,D,d),we=new Set,Ce=new Map,Ve=new Map,Fe="void"===r,qe={params:hve(D,h),delay:this.ast.options?.delay},nt=u?[]:LM(n,e,this.ast.animation,s,a,I,V,qe,l,d);let dt=0;if(nt.forEach(Et=>{dt=Math.max(Et.duration+Et.delay,dt)}),d.length)return O$(e,this._triggerName,i,r,Fe,I,V,[],[],Ce,Ve,dt,d);nt.forEach(Et=>{const Bt=Et.element,tn=T1(Ce,Bt,new Set);Et.preStyleProps.forEach(En=>tn.add(En));const on=T1(Ve,Bt,new Set);Et.postStyleProps.forEach(En=>on.add(En)),Bt!==e&&we.add(Bt)});const mt=Ag(we.values());return O$(e,this._triggerName,i,r,Fe,I,V,nt,mt,Ce,Ve,dt)}}function hve(t,n){const e=k8(n);for(const i in t)t.hasOwnProperty(i)&&null!=t[i]&&(e[i]=t[i]);return e}class pve{constructor(n,e,i){this.styles=n,this.defaultParams=e,this.normalizer=i}buildStyles(n,e){const i=new Map,r=k8(this.defaultParams);return Object.keys(n).forEach(s=>{const a=n[s];null!==a&&(r[s]=a)}),this.styles.styles.forEach(s=>{"string"!=typeof s&&s.forEach((a,o)=>{a&&(a=E8(a,r,e));const c=this.normalizer.normalizePropertyName(o,e);a=this.normalizer.normalizeStyleValue(o,c,a,e),i.set(o,a)})}),i}}class gve{constructor(n,e,i){this.name=n,this.ast=e,this._normalizer=i,this.transitionFactories=[],this.states=new Map,e.states.forEach(r=>{this.states.set(r.name,new pve(r.style,r.options&&r.options.params||{},i))}),V$(this.states,"true","1"),V$(this.states,"false","0"),e.transitions.forEach(r=>{this.transitionFactories.push(new H$(n,r,this.states))}),this.fallbackTransition=function vve(t,n,e){return new H$(t,{type:1,animation:{type:2,steps:[],options:null},matchers:[(a,o)=>!0],options:null,queryCount:0,depCount:0},n)}(n,this.states)}get containsQueries(){return this.ast.queryCount>0}matchTransition(n,e,i,r){return this.transitionFactories.find(a=>a.match(n,e,i,r))||null}matchStyles(n,e,i){return this.fallbackTransition.buildStyles(n,e,i)}}function V$(t,n,e){t.has(n)?t.has(e)||t.set(e,t.get(n)):t.has(e)&&t.set(n,t.get(e))}const yve=new Rg;class _ve{constructor(n,e,i){this.bodyNode=n,this._driver=e,this._normalizer=i,this._animations=new Map,this._playersById=new Map,this.players=[]}register(n,e){const i=[],s=DM(this._driver,e,i,[]);if(i.length)throw function xge(t){return new kt(3503,!1)}();this._animations.set(n,s)}_buildPlayer(n,e,i){const r=n.element,s=w$(this._normalizer,n.keyframes,e,i);return this._driver.animate(r,s,n.duration,n.delay,n.easing,[],!0)}create(n,e,i={}){const r=[],s=this._animations.get(n);let a;const o=new Map;if(s?(a=LM(this._driver,e,s,kM,Mg,new Map,new Map,i,yve,r),a.forEach(u=>{const d=T1(o,u.element,new Map);u.postStyleProps.forEach(h=>d.set(h,null))})):(r.push(function Tge(){return new kt(3300,!1)}()),a=[]),r.length)throw function Mge(t){return new kt(3504,!1)}();o.forEach((u,d)=>{u.forEach((h,y)=>{u.set(y,this._driver.computeStyle(d,y,wl))})});const l=O3(a.map(u=>{const d=o.get(u.element);return this._buildPlayer(u,new Map,d)}));return this._playersById.set(n,l),l.onDestroy(()=>this.destroy(n)),this.players.push(l),l}destroy(n){const e=this._getPlayer(n);e.destroy(),this._playersById.delete(n);const i=this.players.indexOf(e);i>=0&&this.players.splice(i,1)}_getPlayer(n){const e=this._playersById.get(n);if(!e)throw function kge(t){return new kt(3301,!1)}();return e}listen(n,e,i,r){const s=xM(e,"","","");return wM(this._getPlayer(n),i,s,r),()=>{}}command(n,e,i,r){if("register"==i)return void this.register(n,r[0]);if("create"==i)return void this.create(n,e,r[0]||{});const s=this._getPlayer(n);switch(i){case"play":s.play();break;case"pause":s.pause();break;case"reset":s.reset();break;case"restart":s.restart();break;case"finish":s.finish();break;case"init":s.init();break;case"setPosition":s.setPosition(parseFloat(r[0]));break;case"destroy":this.destroy(n)}}}const F$="ng-animate-queued",HM="ng-animate-disabled",Tve=[],B$={namespaceId:"",setForRemoval:!1,setForMove:!1,hasAnimation:!1,removedBeforeQueried:!1},Mve={namespaceId:"",setForMove:!1,setForRemoval:!1,hasAnimation:!1,removedBeforeQueried:!0},B2="__ng_removed";class VM{get params(){return this.options.params}constructor(n,e=""){this.namespaceId=e;const i=n&&n.hasOwnProperty("value");if(this.value=function Ave(t){return t??null}(i?n.value:n),i){const s=k8(n);delete s.value,this.options=s}else this.options={};this.options.params||(this.options.params={})}absorbOptions(n){const e=n.params;if(e){const i=this.options.params;Object.keys(e).forEach(r=>{null==i[r]&&(i[r]=e[r])})}}}const A8="void",FM=new VM(A8);class kve{constructor(n,e,i){this.id=n,this.hostElement=e,this._engine=i,this.players=[],this._triggers=new Map,this._queue=[],this._elementListeners=new Map,this._hostClassName="ng-tns-"+n,n2(e,this._hostClassName)}listen(n,e,i,r){if(!this._triggers.has(e))throw function Sge(t,n){return new kt(3302,!1)}();if(null==i||0==i.length)throw function Ege(t){return new kt(3303,!1)}();if(!function Ive(t){return"start"==t||"done"==t}(i))throw function Age(t,n){return new kt(3400,!1)}();const s=T1(this._elementListeners,n,[]),a={name:e,phase:i,callback:r};s.push(a);const o=T1(this._engine.statesByElement,n,new Map);return o.has(e)||(n2(n,kg),n2(n,kg+"-"+e),o.set(e,FM)),()=>{this._engine.afterFlush(()=>{const c=s.indexOf(a);c>=0&&s.splice(c,1),this._triggers.has(e)||o.delete(e)})}}register(n,e){return!this._triggers.has(n)&&(this._triggers.set(n,e),!0)}_getTrigger(n){const e=this._triggers.get(n);if(!e)throw function Ige(t){return new kt(3401,!1)}();return e}trigger(n,e,i,r=!0){const s=this._getTrigger(e),a=new BM(this.id,e,n);let o=this._engine.statesByElement.get(n);o||(n2(n,kg),n2(n,kg+"-"+e),this._engine.statesByElement.set(n,o=new Map));let c=o.get(e);const l=new VM(i,this.id);if(!(i&&i.hasOwnProperty("value"))&&c&&l.absorbOptions(c.options),o.set(e,l),c||(c=FM),l.value!==A8&&c.value===l.value){if(!function Rve(t,n){const e=Object.keys(t),i=Object.keys(n);if(e.length!=i.length)return!1;for(let r=0;r<e.length;r++){const s=e[r];if(!n.hasOwnProperty(s)||t[s]!==n[s])return!1}return!0}(c.params,l.params)){const D=[],V=s.matchStyles(c.value,c.params,D),we=s.matchStyles(l.value,l.params,D);D.length?this._engine.reportError(D):this._engine.afterFlush(()=>{D4(n,V),Cc(n,we)})}return}const h=T1(this._engine.playersByElement,n,[]);h.forEach(D=>{D.namespaceId==this.id&&D.triggerName==e&&D.queued&&D.destroy()});let y=s.matchTransition(c.value,l.value,n,l.params),I=!1;if(!y){if(!r)return;y=s.fallbackTransition,I=!0}return this._engine.totalQueuedPlayers++,this._queue.push({element:n,triggerName:e,transition:y,fromState:c,toState:l,player:a,isFallbackTransition:I}),I||(n2(n,F$),a.onStart(()=>{ld(n,F$)})),a.onDone(()=>{let D=this.players.indexOf(a);D>=0&&this.players.splice(D,1);const V=this._engine.playersByElement.get(n);if(V){let we=V.indexOf(a);we>=0&&V.splice(we,1)}}),this.players.push(a),h.push(a),a}deregister(n){this._triggers.delete(n),this._engine.statesByElement.forEach(e=>e.delete(n)),this._elementListeners.forEach((e,i)=>{this._elementListeners.set(i,e.filter(r=>r.name!=n))})}clearElementCache(n){this._engine.statesByElement.delete(n),this._elementListeners.delete(n);const e=this._engine.playersByElement.get(n);e&&(e.forEach(i=>i.destroy()),this._engine.playersByElement.delete(n))}_signalRemovalForInnerTriggers(n,e){const i=this._engine.driver.query(n,Sg,!0);i.forEach(r=>{if(r[B2])return;const s=this._engine.fetchNamespacesByElement(r);s.size?s.forEach(a=>a.triggerLeaveAnimation(r,e,!1,!0)):this.clearElementCache(r)}),this._engine.afterFlushAnimationsDone(()=>i.forEach(r=>this.clearElementCache(r)))}triggerLeaveAnimation(n,e,i,r){const s=this._engine.statesByElement.get(n),a=new Map;if(s){const o=[];if(s.forEach((c,l)=>{if(a.set(l,c.value),this._triggers.has(l)){const u=this.trigger(n,l,A8,r);u&&o.push(u)}}),o.length)return this._engine.markElementAsRemoved(this.id,n,!0,e,a),i&&O3(o).onDone(()=>this._engine.processLeaveNode(n)),!0}return!1}prepareLeaveAnimationListeners(n){const e=this._elementListeners.get(n),i=this._engine.statesByElement.get(n);if(e&&i){const r=new Set;e.forEach(s=>{const a=s.name;if(r.has(a))return;r.add(a);const c=this._triggers.get(a).fallbackTransition,l=i.get(a)||FM,u=new VM(A8),d=new BM(this.id,a,n);this._engine.totalQueuedPlayers++,this._queue.push({element:n,triggerName:a,transition:c,fromState:l,toState:u,player:d,isFallbackTransition:!0})})}}removeNode(n,e){const i=this._engine;if(n.childElementCount&&this._signalRemovalForInnerTriggers(n,e),this.triggerLeaveAnimation(n,e,!0))return;let r=!1;if(i.totalAnimations){const s=i.players.length?i.playersByQueriedElement.get(n):[];if(s&&s.length)r=!0;else{let a=n;for(;a=a.parentNode;)if(i.statesByElement.get(a)){r=!0;break}}}if(this.prepareLeaveAnimationListeners(n),r)i.markElementAsRemoved(this.id,n,!1,e);else{const s=n[B2];(!s||s===B$)&&(i.afterFlush(()=>this.clearElementCache(n)),i.destroyInnerAnimations(n),i._onRemovalComplete(n,e))}}insertNode(n,e){n2(n,this._hostClassName)}drainQueuedTransitions(n){const e=[];return this._queue.forEach(i=>{const r=i.player;if(r.destroyed)return;const s=i.element,a=this._elementListeners.get(s);a&&a.forEach(o=>{if(o.name==i.triggerName){const c=xM(s,i.triggerName,i.fromState.value,i.toState.value);c._data=n,wM(i.player,o.phase,c,o.callback)}}),r.markedForDestroy?this._engine.afterFlush(()=>{r.destroy()}):e.push(i)}),this._queue=[],e.sort((i,r)=>{const s=i.transition.ast.depCount,a=r.transition.ast.depCount;return 0==s||0==a?s-a:this._engine.driver.containsElement(i.element,r.element)?1:-1})}destroy(n){this.players.forEach(e=>e.destroy()),this._signalRemovalForInnerTriggers(this.hostElement,n)}}class Sve{_onRemovalComplete(n,e){this.onRemovalComplete(n,e)}constructor(n,e,i){this.bodyNode=n,this.driver=e,this._normalizer=i,this.players=[],this.newHostElements=new Map,this.playersByElement=new Map,this.playersByQueriedElement=new Map,this.statesByElement=new Map,this.disabledNodes=new Set,this.totalAnimations=0,this.totalQueuedPlayers=0,this._namespaceLookup={},this._namespaceList=[],this._flushFns=[],this._whenQuietFns=[],this.namespacesByHostElement=new Map,this.collectedEnterElements=[],this.collectedLeaveElements=[],this.onRemovalComplete=(r,s)=>{}}get queuedPlayers(){const n=[];return this._namespaceList.forEach(e=>{e.players.forEach(i=>{i.queued&&n.push(i)})}),n}createNamespace(n,e){const i=new kve(n,e,this);return this.bodyNode&&this.driver.containsElement(this.bodyNode,e)?this._balanceNamespaceList(i,e):(this.newHostElements.set(e,i),this.collectEnterElement(e)),this._namespaceLookup[n]=i}_balanceNamespaceList(n,e){const i=this._namespaceList,r=this.namespacesByHostElement;if(i.length-1>=0){let a=!1,o=this.driver.getParentElement(e);for(;o;){const c=r.get(o);if(c){const l=i.indexOf(c);i.splice(l+1,0,n),a=!0;break}o=this.driver.getParentElement(o)}a||i.unshift(n)}else i.push(n);return r.set(e,n),n}register(n,e){let i=this._namespaceLookup[n];return i||(i=this.createNamespace(n,e)),i}registerTrigger(n,e,i){let r=this._namespaceLookup[n];r&&r.register(e,i)&&this.totalAnimations++}destroy(n,e){n&&(this.afterFlush(()=>{}),this.afterFlushAnimationsDone(()=>{const i=this._fetchNamespace(n);this.namespacesByHostElement.delete(i.hostElement);const r=this._namespaceList.indexOf(i);r>=0&&this._namespaceList.splice(r,1),i.destroy(e),delete this._namespaceLookup[n]}))}_fetchNamespace(n){return this._namespaceLookup[n]}fetchNamespacesByElement(n){const e=new Set,i=this.statesByElement.get(n);if(i)for(let r of i.values())if(r.namespaceId){const s=this._fetchNamespace(r.namespaceId);s&&e.add(s)}return e}trigger(n,e,i,r){if(zg(e)){const s=this._fetchNamespace(n);if(s)return s.trigger(e,i,r),!0}return!1}insertNode(n,e,i,r){if(!zg(e))return;const s=e[B2];if(s&&s.setForRemoval){s.setForRemoval=!1,s.setForMove=!0;const a=this.collectedLeaveElements.indexOf(e);a>=0&&this.collectedLeaveElements.splice(a,1)}if(n){const a=this._fetchNamespace(n);a&&a.insertNode(e,i)}r&&this.collectEnterElement(e)}collectEnterElement(n){this.collectedEnterElements.push(n)}markElementAsDisabled(n,e){e?this.disabledNodes.has(n)||(this.disabledNodes.add(n),n2(n,HM)):this.disabledNodes.has(n)&&(this.disabledNodes.delete(n),ld(n,HM))}removeNode(n,e,i){if(zg(e)){const r=n?this._fetchNamespace(n):null;r?r.removeNode(e,i):this.markElementAsRemoved(n,e,!1,i);const s=this.namespacesByHostElement.get(e);s&&s.id!==n&&s.removeNode(e,i)}else this._onRemovalComplete(e,i)}markElementAsRemoved(n,e,i,r,s){this.collectedLeaveElements.push(e),e[B2]={namespaceId:n,setForRemoval:r,hasAnimation:i,removedBeforeQueried:!1,previousTriggersValues:s}}listen(n,e,i,r,s){return zg(e)?this._fetchNamespace(n).listen(e,i,r,s):()=>{}}_buildInstruction(n,e,i,r,s){return n.transition.build(this.driver,n.element,n.fromState.value,n.toState.value,i,r,n.fromState.options,n.toState.options,e,s)}destroyInnerAnimations(n){let e=this.driver.query(n,Sg,!0);e.forEach(i=>this.destroyActiveAnimationsForElement(i)),0!=this.playersByQueriedElement.size&&(e=this.driver.query(n,SM,!0),e.forEach(i=>this.finishActiveQueriedAnimationOnElement(i)))}destroyActiveAnimationsForElement(n){const e=this.playersByElement.get(n);e&&e.forEach(i=>{i.queued?i.markedForDestroy=!0:i.destroy()})}finishActiveQueriedAnimationOnElement(n){const e=this.playersByQueriedElement.get(n);e&&e.forEach(i=>i.finish())}whenRenderingDone(){return new Promise(n=>{if(this.players.length)return O3(this.players).onDone(()=>n());n()})}processLeaveNode(n){const e=n[B2];if(e&&e.setForRemoval){if(n[B2]=B$,e.namespaceId){this.destroyInnerAnimations(n);const i=this._fetchNamespace(e.namespaceId);i&&i.clearElementCache(n)}this._onRemovalComplete(n,e.setForRemoval)}n.classList?.contains(HM)&&this.markElementAsDisabled(n,!1),this.driver.query(n,".ng-animate-disabled",!0).forEach(i=>{this.markElementAsDisabled(i,!1)})}flush(n=-1){let e=[];if(this.newHostElements.size&&(this.newHostElements.forEach((i,r)=>this._balanceNamespaceList(i,r)),this.newHostElements.clear()),this.totalAnimations&&this.collectedEnterElements.length)for(let i=0;i<this.collectedEnterElements.length;i++)n2(this.collectedEnterElements[i],"ng-star-inserted");if(this._namespaceList.length&&(this.totalQueuedPlayers||this.collectedLeaveElements.length)){const i=[];try{e=this._flushAnimations(i,n)}finally{for(let r=0;r<i.length;r++)i[r]()}}else for(let i=0;i<this.collectedLeaveElements.length;i++)this.processLeaveNode(this.collectedLeaveElements[i]);if(this.totalQueuedPlayers=0,this.collectedEnterElements.length=0,this.collectedLeaveElements.length=0,this._flushFns.forEach(i=>i()),this._flushFns=[],this._whenQuietFns.length){const i=this._whenQuietFns;this._whenQuietFns=[],e.length?O3(e).onDone(()=>{i.forEach(r=>r())}):i.forEach(r=>r())}}reportError(n){throw function Dge(t){return new kt(3402,!1)}()}_flushAnimations(n,e){const i=new Rg,r=[],s=new Map,a=[],o=new Map,c=new Map,l=new Map,u=new Set;this.disabledNodes.forEach(Vt=>{u.add(Vt);const Zt=this.driver.query(Vt,".ng-animate-queued",!0);for(let xt=0;xt<Zt.length;xt++)u.add(Zt[xt])});const d=this.bodyNode,h=Array.from(this.statesByElement.keys()),y=j$(h,this.collectedEnterElements),I=new Map;let D=0;y.forEach((Vt,Zt)=>{const xt=kM+D++;I.set(Zt,xt),Vt.forEach(Tt=>n2(Tt,xt))});const V=[],we=new Set,Ce=new Set;for(let Vt=0;Vt<this.collectedLeaveElements.length;Vt++){const Zt=this.collectedLeaveElements[Vt],xt=Zt[B2];xt&&xt.setForRemoval&&(V.push(Zt),we.add(Zt),xt.hasAnimation?this.driver.query(Zt,".ng-star-inserted",!0).forEach(Tt=>we.add(Tt)):Ce.add(Zt))}const Ve=new Map,Fe=j$(h,Array.from(we));Fe.forEach((Vt,Zt)=>{const xt=Mg+D++;Ve.set(Zt,xt),Vt.forEach(Tt=>n2(Tt,xt))}),n.push(()=>{y.forEach((Vt,Zt)=>{const xt=I.get(Zt);Vt.forEach(Tt=>ld(Tt,xt))}),Fe.forEach((Vt,Zt)=>{const xt=Ve.get(Zt);Vt.forEach(Tt=>ld(Tt,xt))}),V.forEach(Vt=>{this.processLeaveNode(Vt)})});const qe=[],nt=[];for(let Vt=this._namespaceList.length-1;Vt>=0;Vt--)this._namespaceList[Vt].drainQueuedTransitions(e).forEach(xt=>{const Tt=xt.player,jt=xt.element;if(qe.push(Tt),this.collectedEnterElements.length){const Vi=jt[B2];if(Vi&&Vi.setForMove){if(Vi.previousTriggersValues&&Vi.previousTriggersValues.has(xt.triggerName)){const Ws=Vi.previousTriggersValues.get(xt.triggerName),gs=this.statesByElement.get(xt.element);if(gs&&gs.has(xt.triggerName)){const t1=gs.get(xt.triggerName);t1.value=Ws,gs.set(xt.triggerName,t1)}}return void Tt.destroy()}}const gn=!d||!this.driver.containsElement(d,jt),dn=Ve.get(jt),Ti=I.get(jt),Hn=this._buildInstruction(xt,i,Ti,dn,gn);if(Hn.errors&&Hn.errors.length)return void nt.push(Hn);if(gn)return Tt.onStart(()=>D4(jt,Hn.fromStyles)),Tt.onDestroy(()=>Cc(jt,Hn.toStyles)),void r.push(Tt);if(xt.isFallbackTransition)return Tt.onStart(()=>D4(jt,Hn.fromStyles)),Tt.onDestroy(()=>Cc(jt,Hn.toStyles)),void r.push(Tt);const Ji=[];Hn.timelines.forEach(Vi=>{Vi.stretchStartingKeyframe=!0,this.disabledNodes.has(Vi.element)||Ji.push(Vi)}),Hn.timelines=Ji,i.append(jt,Hn.timelines),a.push({instruction:Hn,player:Tt,element:jt}),Hn.queriedElements.forEach(Vi=>T1(o,Vi,[]).push(Tt)),Hn.preStyleProps.forEach((Vi,Ws)=>{if(Vi.size){let gs=c.get(Ws);gs||c.set(Ws,gs=new Set),Vi.forEach((t1,zu)=>gs.add(zu))}}),Hn.postStyleProps.forEach((Vi,Ws)=>{let gs=l.get(Ws);gs||l.set(Ws,gs=new Set),Vi.forEach((t1,zu)=>gs.add(zu))})});if(nt.length){const Vt=[];nt.forEach(Zt=>{Vt.push(function Nge(t,n){return new kt(3505,!1)}())}),qe.forEach(Zt=>Zt.destroy()),this.reportError(Vt)}const dt=new Map,mt=new Map;a.forEach(Vt=>{const Zt=Vt.element;i.has(Zt)&&(mt.set(Zt,Zt),this._beforeAnimationBuild(Vt.player.namespaceId,Vt.instruction,dt))}),r.forEach(Vt=>{const Zt=Vt.element;this._getPreviousPlayers(Zt,!1,Vt.namespaceId,Vt.triggerName,null).forEach(Tt=>{T1(dt,Zt,[]).push(Tt),Tt.destroy()})});const Et=V.filter(Vt=>q$(Vt,c,l)),Bt=new Map;$$(Bt,this.driver,Ce,l,wl).forEach(Vt=>{q$(Vt,c,l)&&Et.push(Vt)});const on=new Map;y.forEach((Vt,Zt)=>{$$(on,this.driver,new Set(Vt),c,"!")}),Et.forEach(Vt=>{const Zt=Bt.get(Vt),xt=on.get(Vt);Bt.set(Vt,new Map([...Zt?.entries()??[],...xt?.entries()??[]]))});const En=[],xi=[],On={};a.forEach(Vt=>{const{element:Zt,player:xt,instruction:Tt}=Vt;if(i.has(Zt)){if(u.has(Zt))return xt.onDestroy(()=>Cc(Zt,Tt.toStyles)),xt.disabled=!0,xt.overrideTotalTime(Tt.totalTime),void r.push(xt);let jt=On;if(mt.size>1){let dn=Zt;const Ti=[];for(;dn=dn.parentNode;){const Hn=mt.get(dn);if(Hn){jt=Hn;break}Ti.push(dn)}Ti.forEach(Hn=>mt.set(Hn,jt))}const gn=this._buildAnimation(xt.namespaceId,Tt,dt,s,on,Bt);if(xt.setRealPlayer(gn),jt===On)En.push(xt);else{const dn=this.playersByElement.get(jt);dn&&dn.length&&(xt.parentPlayer=O3(dn)),r.push(xt)}}else D4(Zt,Tt.fromStyles),xt.onDestroy(()=>Cc(Zt,Tt.toStyles)),xi.push(xt),u.has(Zt)&&r.push(xt)}),xi.forEach(Vt=>{const Zt=s.get(Vt.element);if(Zt&&Zt.length){const xt=O3(Zt);Vt.setRealPlayer(xt)}}),r.forEach(Vt=>{Vt.parentPlayer?Vt.syncPlayerEvents(Vt.parentPlayer):Vt.destroy()});for(let Vt=0;Vt<V.length;Vt++){const Zt=V[Vt],xt=Zt[B2];if(ld(Zt,Mg),xt&&xt.hasAnimation)continue;let Tt=[];if(o.size){let gn=o.get(Zt);gn&&gn.length&&Tt.push(...gn);let dn=this.driver.query(Zt,SM,!0);for(let Ti=0;Ti<dn.length;Ti++){let Hn=o.get(dn[Ti]);Hn&&Hn.length&&Tt.push(...Hn)}}const jt=Tt.filter(gn=>!gn.destroyed);jt.length?Dve(this,Zt,jt):this.processLeaveNode(Zt)}return V.length=0,En.forEach(Vt=>{this.players.push(Vt),Vt.onDone(()=>{Vt.destroy();const Zt=this.players.indexOf(Vt);this.players.splice(Zt,1)}),Vt.play()}),En}afterFlush(n){this._flushFns.push(n)}afterFlushAnimationsDone(n){this._whenQuietFns.push(n)}_getPreviousPlayers(n,e,i,r,s){let a=[];if(e){const o=this.playersByQueriedElement.get(n);o&&(a=o)}else{const o=this.playersByElement.get(n);if(o){const c=!s||s==A8;o.forEach(l=>{l.queued||!c&&l.triggerName!=r||a.push(l)})}}return(i||r)&&(a=a.filter(o=>!(i&&i!=o.namespaceId||r&&r!=o.triggerName))),a}_beforeAnimationBuild(n,e,i){const s=e.element,a=e.isRemovalTransition?void 0:n,o=e.isRemovalTransition?void 0:e.triggerName;for(const c of e.timelines){const l=c.element,u=l!==s,d=T1(i,l,[]);this._getPreviousPlayers(l,u,a,o,e.toState).forEach(y=>{const I=y.getRealPlayer();I.beforeDestroy&&I.beforeDestroy(),y.destroy(),d.push(y)})}D4(s,e.fromStyles)}_buildAnimation(n,e,i,r,s,a){const o=e.triggerName,c=e.element,l=[],u=new Set,d=new Set,h=e.timelines.map(I=>{const D=I.element;u.add(D);const V=D[B2];if(V&&V.removedBeforeQueried)return new M8(I.duration,I.delay);const we=D!==c,Ce=function Nve(t){const n=[];return W$(t,n),n}((i.get(D)||Tve).map(dt=>dt.getRealPlayer())).filter(dt=>!!dt.element&&dt.element===D),Ve=s.get(D),Fe=a.get(D),qe=w$(this._normalizer,I.keyframes,Ve,Fe),nt=this._buildPlayer(I,qe,Ce);if(I.subTimeline&&r&&d.add(D),we){const dt=new BM(n,o,D);dt.setRealPlayer(nt),l.push(dt)}return nt});l.forEach(I=>{T1(this.playersByQueriedElement,I.element,[]).push(I),I.onDone(()=>function Eve(t,n,e){let i=t.get(n);if(i){if(i.length){const r=i.indexOf(e);i.splice(r,1)}0==i.length&&t.delete(n)}return i}(this.playersByQueriedElement,I.element,I))}),u.forEach(I=>n2(I,E$));const y=O3(h);return y.onDestroy(()=>{u.forEach(I=>ld(I,E$)),Cc(c,e.toStyles)}),d.forEach(I=>{T1(r,I,[]).push(y)}),y}_buildPlayer(n,e,i){return e.length>0?this.driver.animate(n.element,e,n.duration,n.delay,n.easing,i):new M8(n.duration,n.delay)}}class BM{constructor(n,e,i){this.namespaceId=n,this.triggerName=e,this.element=i,this._player=new M8,this._containsRealPlayer=!1,this._queuedCallbacks=new Map,this.destroyed=!1,this.parentPlayer=null,this.markedForDestroy=!1,this.disabled=!1,this.queued=!0,this.totalTime=0}setRealPlayer(n){this._containsRealPlayer||(this._player=n,this._queuedCallbacks.forEach((e,i)=>{e.forEach(r=>wM(n,i,void 0,r))}),this._queuedCallbacks.clear(),this._containsRealPlayer=!0,this.overrideTotalTime(n.totalTime),this.queued=!1)}getRealPlayer(){return this._player}overrideTotalTime(n){this.totalTime=n}syncPlayerEvents(n){const e=this._player;e.triggerCallback&&n.onStart(()=>e.triggerCallback("start")),n.onDone(()=>this.finish()),n.onDestroy(()=>this.destroy())}_queueEvent(n,e){T1(this._queuedCallbacks,n,[]).push(e)}onDone(n){this.queued&&this._queueEvent("done",n),this._player.onDone(n)}onStart(n){this.queued&&this._queueEvent("start",n),this._player.onStart(n)}onDestroy(n){this.queued&&this._queueEvent("destroy",n),this._player.onDestroy(n)}init(){this._player.init()}hasStarted(){return!this.queued&&this._player.hasStarted()}play(){!this.queued&&this._player.play()}pause(){!this.queued&&this._player.pause()}restart(){!this.queued&&this._player.restart()}finish(){this._player.finish()}destroy(){this.destroyed=!0,this._player.destroy()}reset(){!this.queued&&this._player.reset()}setPosition(n){this.queued||this._player.setPosition(n)}getPosition(){return this.queued?0:this._player.getPosition()}triggerCallback(n){const e=this._player;e.triggerCallback&&e.triggerCallback(n)}}function zg(t){return t&&1===t.nodeType}function U$(t,n){const e=t.style.display;return t.style.display=n??"none",e}function $$(t,n,e,i,r){const s=[];e.forEach(c=>s.push(U$(c)));const a=[];i.forEach((c,l)=>{const u=new Map;c.forEach(d=>{const h=n.computeStyle(l,d,r);u.set(d,h),(!h||0==h.length)&&(l[B2]=Mve,a.push(l))}),t.set(l,u)});let o=0;return e.forEach(c=>U$(c,s[o++])),a}function j$(t,n){const e=new Map;if(t.forEach(o=>e.set(o,[])),0==n.length)return e;const r=new Set(n),s=new Map;function a(o){if(!o)return 1;let c=s.get(o);if(c)return c;const l=o.parentNode;return c=e.has(l)?l:r.has(l)?1:a(l),s.set(o,c),c}return n.forEach(o=>{const c=a(o);1!==c&&e.get(c).push(o)}),e}function n2(t,n){t.classList?.add(n)}function ld(t,n){t.classList?.remove(n)}function Dve(t,n,e){O3(e).onDone(()=>t.processLeaveNode(n))}function W$(t,n){for(let e=0;e<t.length;e++){const i=t[e];i instanceof _$?W$(i.players,n):n.push(i)}}function q$(t,n,e){const i=e.get(t);if(!i)return!1;let r=n.get(t);return r?i.forEach(s=>r.add(s)):n.set(t,i),e.delete(t),!0}class Og{constructor(n,e,i){this.bodyNode=n,this._driver=e,this._normalizer=i,this._triggerCache={},this.onRemovalComplete=(r,s)=>{},this._transitionEngine=new Sve(n,e,i),this._timelineEngine=new _ve(n,e,i),this._transitionEngine.onRemovalComplete=(r,s)=>this.onRemovalComplete(r,s)}registerTrigger(n,e,i,r,s){const a=n+"-"+r;let o=this._triggerCache[a];if(!o){const c=[],u=DM(this._driver,s,c,[]);if(c.length)throw function wge(t,n){return new kt(3404,!1)}();o=function mve(t,n,e){return new gve(t,n,e)}(r,u,this._normalizer),this._triggerCache[a]=o}this._transitionEngine.registerTrigger(e,r,o)}register(n,e){this._transitionEngine.register(n,e)}destroy(n,e){this._transitionEngine.destroy(n,e)}onInsert(n,e,i,r){this._transitionEngine.insertNode(n,e,i,r)}onRemove(n,e,i){this._transitionEngine.removeNode(n,e,i)}disableAnimations(n,e){this._transitionEngine.markElementAsDisabled(n,e)}process(n,e,i,r){if("@"==i.charAt(0)){const[s,a]=C$(i);this._timelineEngine.command(s,e,a,r)}else this._transitionEngine.trigger(n,e,i,r)}listen(n,e,i,r,s){if("@"==i.charAt(0)){const[a,o]=C$(i);return this._timelineEngine.listen(a,e,o,s)}return this._transitionEngine.listen(n,e,i,r,s)}flush(n=-1){this._transitionEngine.flush(n)}get players(){return[...this._transitionEngine.players,...this._timelineEngine.players]}whenRenderingDone(){return this._transitionEngine.whenRenderingDone()}afterFlushAnimationsDone(n){this._transitionEngine.afterFlushAnimationsDone(n)}}let Pve=(()=>{class t{static#e=this.initialStylesByElement=new WeakMap;constructor(e,i,r){this._element=e,this._startStyles=i,this._endStyles=r,this._state=0;let s=t.initialStylesByElement.get(e);s||t.initialStylesByElement.set(e,s=new Map),this._initialStyles=s}start(){this._state<1&&(this._startStyles&&Cc(this._element,this._startStyles,this._initialStyles),this._state=1)}finish(){this.start(),this._state<2&&(Cc(this._element,this._initialStyles),this._endStyles&&(Cc(this._element,this._endStyles),this._endStyles=null),this._state=1)}destroy(){this.finish(),this._state<3&&(t.initialStylesByElement.delete(this._element),this._startStyles&&(D4(this._element,this._startStyles),this._endStyles=null),this._endStyles&&(D4(this._element,this._endStyles),this._endStyles=null),Cc(this._element,this._initialStyles),this._state=3)}}return t})();function UM(t){let n=null;return t.forEach((e,i)=>{(function zve(t){return"display"===t||"position"===t})(i)&&(n=n||new Map,n.set(i,e))}),n}class G${constructor(n,e,i,r){this.element=n,this.keyframes=e,this.options=i,this._specialStyles=r,this._onDoneFns=[],this._onStartFns=[],this._onDestroyFns=[],this._initialized=!1,this._finished=!1,this._started=!1,this._destroyed=!1,this._originalOnDoneFns=[],this._originalOnStartFns=[],this.time=0,this.parentPlayer=null,this.currentSnapshot=new Map,this._duration=i.duration,this._delay=i.delay||0,this.time=this._duration+this._delay}_onFinish(){this._finished||(this._finished=!0,this._onDoneFns.forEach(n=>n()),this._onDoneFns=[])}init(){this._buildPlayer(),this._preparePlayerBeforeStart()}_buildPlayer(){if(this._initialized)return;this._initialized=!0;const n=this.keyframes;this.domPlayer=this._triggerWebAnimation(this.element,n,this.options),this._finalKeyframe=n.length?n[n.length-1]:new Map;const e=()=>this._onFinish();this.domPlayer.addEventListener("finish",e),this.onDestroy(()=>{this.domPlayer.removeEventListener("finish",e)})}_preparePlayerBeforeStart(){this._delay?this._resetDomPlayerState():this.domPlayer.pause()}_convertKeyframesToObject(n){const e=[];return n.forEach(i=>{e.push(Object.fromEntries(i))}),e}_triggerWebAnimation(n,e,i){return n.animate(this._convertKeyframesToObject(e),i)}onStart(n){this._originalOnStartFns.push(n),this._onStartFns.push(n)}onDone(n){this._originalOnDoneFns.push(n),this._onDoneFns.push(n)}onDestroy(n){this._onDestroyFns.push(n)}play(){this._buildPlayer(),this.hasStarted()||(this._onStartFns.forEach(n=>n()),this._onStartFns=[],this._started=!0,this._specialStyles&&this._specialStyles.start()),this.domPlayer.play()}pause(){this.init(),this.domPlayer.pause()}finish(){this.init(),this._specialStyles&&this._specialStyles.finish(),this._onFinish(),this.domPlayer.finish()}reset(){this._resetDomPlayerState(),this._destroyed=!1,this._finished=!1,this._started=!1,this._onStartFns=this._originalOnStartFns,this._onDoneFns=this._originalOnDoneFns}_resetDomPlayerState(){this.domPlayer&&this.domPlayer.cancel()}restart(){this.reset(),this.play()}hasStarted(){return this._started}destroy(){this._destroyed||(this._destroyed=!0,this._resetDomPlayerState(),this._onFinish(),this._specialStyles&&this._specialStyles.destroy(),this._onDestroyFns.forEach(n=>n()),this._onDestroyFns=[])}setPosition(n){void 0===this.domPlayer&&this.init(),this.domPlayer.currentTime=n*this.time}getPosition(){return+(this.domPlayer.currentTime??0)/this.time}get totalTime(){return this._delay+this._duration}beforeDestroy(){const n=new Map;this.hasStarted()&&this._finalKeyframe.forEach((i,r)=>{"offset"!==r&&n.set(r,this._finished?i:N$(this.element,r))}),this.currentSnapshot=n}triggerCallback(n){const e="start"===n?this._onStartFns:this._onDoneFns;e.forEach(i=>i()),e.length=0}}class Ove{validateStyleProperty(n){return!0}validateAnimatableStyleProperty(n){return!0}matchesElement(n,e){return!1}containsElement(n,e){return T$(n,e)}getParentElement(n){return TM(n)}query(n,e,i){return M$(n,e,i)}computeStyle(n,e,i){return window.getComputedStyle(n)[e]}animate(n,e,i,r,s,a=[]){const c={duration:i,delay:r,fill:0==r?"both":"forwards"};s&&(c.easing=s);const l=new Map,u=a.filter(y=>y instanceof G$);(function jge(t,n){return 0===t||0===n})(i,r)&&u.forEach(y=>{y.currentSnapshot.forEach((I,D)=>l.set(D,I))});let d=function Bge(t){return t.length?t[0]instanceof Map?t:t.map(n=>A$(n)):[]}(e).map(y=>H3(y));d=function Wge(t,n,e){if(e.size&&n.length){let i=n[0],r=[];if(e.forEach((s,a)=>{i.has(a)||r.push(a),i.set(a,s)}),r.length)for(let s=1;s<n.length;s++){let a=n[s];r.forEach(o=>a.set(o,N$(t,o)))}}return n}(n,d,l);const h=function Lve(t,n){let e=null,i=null;return Array.isArray(n)&&n.length?(e=UM(n[0]),n.length>1&&(i=UM(n[n.length-1]))):n instanceof Map&&(e=UM(n)),e||i?new Pve(t,e,i):null}(n,d);return new G$(n,d,c,h)}}let Hve=(()=>{class t extends v${constructor(e,i){super(),this._nextAnimationId=0,this._renderer=e.createRenderer(i.body,{id:"0",encapsulation:Co.None,styles:[],data:{animation:[]}})}build(e){const i=this._nextAnimationId.toString();this._nextAnimationId++;const r=Array.isArray(e)?y$(e):e;return Z$(this._renderer,null,i,"register",[r]),new Vve(i,this._renderer)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(S6),gt(Pi))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();class Vve extends X9e{constructor(n,e){super(),this._id=n,this._renderer=e}create(n,e){return new Fve(this._id,n,e||{},this._renderer)}}class Fve{constructor(n,e,i,r){this.id=n,this.element=e,this._renderer=r,this.parentPlayer=null,this._started=!1,this.totalTime=0,this._command("create",i)}_listen(n,e){return this._renderer.listen(this.element,`@@${this.id}:${n}`,e)}_command(n,...e){return Z$(this._renderer,this.element,this.id,n,e)}onDone(n){this._listen("done",n)}onStart(n){this._listen("start",n)}onDestroy(n){this._listen("destroy",n)}init(){this._command("init")}hasStarted(){return this._started}play(){this._command("play"),this._started=!0}pause(){this._command("pause")}restart(){this._command("restart")}finish(){this._command("finish")}destroy(){this._command("destroy")}reset(){this._command("reset"),this._started=!1}setPosition(n){this._command("setPosition",n)}getPosition(){return this._renderer.engine.players[+this.id]?.getPosition()??0}}function Z$(t,n,e,i,r){return t.setProperty(n,`@@${e}:${i}`,r)}const Y$="@.disabled";let Bve=(()=>{class t{constructor(e,i,r){this.delegate=e,this.engine=i,this._zone=r,this._currentId=0,this._microtaskId=1,this._animationCallbacksBuffer=[],this._rendererCache=new Map,this._cdRecurDepth=0,i.onRemovalComplete=(s,a)=>{const o=a?.parentNode(s);o&&a.removeChild(o,s)}}createRenderer(e,i){const s=this.delegate.createRenderer(e,i);if(!(e&&i&&i.data&&i.data.animation)){let u=this._rendererCache.get(s);return u||(u=new K$("",s,this.engine,()=>this._rendererCache.delete(s)),this._rendererCache.set(s,u)),u}const a=i.id,o=i.id+"-"+this._currentId;this._currentId++,this.engine.register(o,e);const c=u=>{Array.isArray(u)?u.forEach(c):this.engine.registerTrigger(a,o,e,u.name,u)};return i.data.animation.forEach(c),new Uve(this,o,s,this.engine)}begin(){this._cdRecurDepth++,this.delegate.begin&&this.delegate.begin()}_scheduleCountTask(){queueMicrotask(()=>{this._microtaskId++})}scheduleListenerCallback(e,i,r){e>=0&&e<this._microtaskId?this._zone.run(()=>i(r)):(0==this._animationCallbacksBuffer.length&&queueMicrotask(()=>{this._zone.run(()=>{this._animationCallbacksBuffer.forEach(s=>{const[a,o]=s;a(o)}),this._animationCallbacksBuffer=[]})}),this._animationCallbacksBuffer.push([i,r]))}end(){this._cdRecurDepth--,0==this._cdRecurDepth&&this._zone.runOutsideAngular(()=>{this._scheduleCountTask(),this.engine.flush(this._microtaskId)}),this.delegate.end&&this.delegate.end()}whenRenderingDone(){return this.engine.whenRenderingDone()}static#e=this.\u0275fac=function(i){return new(i||t)(gt(S6),gt(Og),gt(Xn))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();class K${constructor(n,e,i,r){this.namespaceId=n,this.delegate=e,this.engine=i,this._onDestroy=r}get data(){return this.delegate.data}destroyNode(n){this.delegate.destroyNode?.(n)}destroy(){this.engine.destroy(this.namespaceId,this.delegate),this.engine.afterFlushAnimationsDone(()=>{queueMicrotask(()=>{this.delegate.destroy()})}),this._onDestroy?.()}createElement(n,e){return this.delegate.createElement(n,e)}createComment(n){return this.delegate.createComment(n)}createText(n){return this.delegate.createText(n)}appendChild(n,e){this.delegate.appendChild(n,e),this.engine.onInsert(this.namespaceId,e,n,!1)}insertBefore(n,e,i,r=!0){this.delegate.insertBefore(n,e,i),this.engine.onInsert(this.namespaceId,e,n,r)}removeChild(n,e,i){this.engine.onRemove(this.namespaceId,e,this.delegate)}selectRootElement(n,e){return this.delegate.selectRootElement(n,e)}parentNode(n){return this.delegate.parentNode(n)}nextSibling(n){return this.delegate.nextSibling(n)}setAttribute(n,e,i,r){this.delegate.setAttribute(n,e,i,r)}removeAttribute(n,e,i){this.delegate.removeAttribute(n,e,i)}addClass(n,e){this.delegate.addClass(n,e)}removeClass(n,e){this.delegate.removeClass(n,e)}setStyle(n,e,i,r){this.delegate.setStyle(n,e,i,r)}removeStyle(n,e,i){this.delegate.removeStyle(n,e,i)}setProperty(n,e,i){"@"==e.charAt(0)&&e==Y$?this.disableAnimations(n,!!i):this.delegate.setProperty(n,e,i)}setValue(n,e){this.delegate.setValue(n,e)}listen(n,e,i){return this.delegate.listen(n,e,i)}disableAnimations(n,e){this.engine.disableAnimations(n,e)}}class Uve extends K${constructor(n,e,i,r,s){super(e,i,r,s),this.factory=n,this.namespaceId=e}setProperty(n,e,i){"@"==e.charAt(0)?"."==e.charAt(1)&&e==Y$?this.disableAnimations(n,i=void 0===i||!!i):this.engine.process(this.namespaceId,n,e.slice(1),i):this.delegate.setProperty(n,e,i)}listen(n,e,i){if("@"==e.charAt(0)){const r=function $ve(t){switch(t){case"body":return document.body;case"document":return document;case"window":return window;default:return t}}(n);let s=e.slice(1),a="";return"@"!=s.charAt(0)&&([s,a]=function jve(t){const n=t.indexOf(".");return[t.substring(0,n),t.slice(n+1)]}(s)),this.engine.listen(this.namespaceId,r,s,a,o=>{this.factory.scheduleListenerCallback(o._data||-1,i,o)})}return this.delegate.listen(n,e,i)}}let Wve=(()=>{class t extends Og{constructor(e,i,r,s){super(e.body,i,r)}ngOnDestroy(){this.flush()}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Pi),gt(MM),gt(zM),gt(P2))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();const X$=[{provide:v$,useClass:Hve},{provide:zM,useFactory:function qve(){return new dve}},{provide:Og,useClass:Wve},{provide:S6,useFactory:function Gve(t,n,e){return new Bve(t,n,e)},deps:[fT,Og,Xn]}],$M=[{provide:MM,useFactory:()=>new Ove},{provide:CP,useValue:"BrowserAnimations"},...X$],Q$=[{provide:MM,useClass:k$},{provide:CP,useValue:"NoopAnimations"},...X$];let Zve=(()=>{class t{static withConfig(e){return{ngModule:t,providers:e.disableAnimations?Q$:$M}}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({providers:$M,imports:[vF]})}return t})();function J$(t){return!!t&&(t instanceof te||Y(t.lift)&&Y(t.subscribe))}function Vg(...t){const n=Zn(t),e=Qt(t),{args:i,keys:r}=xF(t);if(0===i.length)return ti([],n);const s=new te(function Yve(t,n,e=H){return i=>{ej(n,()=>{const{length:r}=t,s=new Array(r);let a=r,o=r;for(let c=0;c<r;c++)ej(n,()=>{const l=ti(t[c],n);let u=!1;l.subscribe(Ze(i,d=>{s[c]=d,u||(u=!0,o--),o||i.next(e(s.slice()))},()=>{--a||i.complete()}))},i)},i)}}(i,n,r?a=>TF(r,a):H));return e?s.pipe(vT(e)):s}function ej(t,n,e){t?N(e,t,n):n()}const Fg=ce(t=>function(){t(this),this.name="EmptyError",this.message="no elements in sequence"});function tj(t){return new te(n=>{lt(t()).subscribe(n)})}function I8(t,n){const e=Y(t)?t:()=>t,i=r=>r.error(e());return new te(n?r=>n.schedule(i,0,r):i)}function jM(){return Ue((t,n)=>{let e=null;t._refCount++;const i=Ze(n,void 0,void 0,void 0,()=>{if(!t||t._refCount<=0||0<--t._refCount)return void(e=null);const r=t._connection,s=e;e=null,r&&(!s||r===s)&&r.unsubscribe(),n.unsubscribe()});t.subscribe(i),i.closed||(e=t.connect())})}class WM extends te{constructor(n,e){super(),this.source=n,this.subjectFactory=e,this._subject=null,this._refCount=0,this._connection=null,le(n)&&(this.lift=n.lift)}_subscribe(n){return this.getSubject().subscribe(n)}getSubject(){const n=this._subject;return(!n||n.isStopped)&&(this._subject=this.subjectFactory()),this._subject}_teardown(){this._refCount=0;const{_connection:n}=this;this._subject=this._connection=null,n?.unsubscribe()}connect(){let n=this._connection;if(!n){n=this._connection=new w;const e=this.getSubject();n.add(this.source.subscribe(Ze(e,void 0,()=>{this._teardown(),e.complete()},i=>{this._teardown(),e.error(i)},()=>this._teardown()))),n.closed&&(this._connection=null,n=w.EMPTY)}return n}refCount(){return jM()(this)}}function Bg(t){return Ue((n,e)=>{let i=!1;n.subscribe(Ze(e,r=>{i=!0,e.next(r)},()=>{i||e.next(t),e.complete()}))})}function nj(t=Kve){return Ue((n,e)=>{let i=!1;n.subscribe(Ze(e,r=>{i=!0,e.next(r)},()=>i?e.complete():e.error(t())))})}function Kve(){return new Fg}function R4(t,n){const e=arguments.length>=2;return i=>i.pipe(t?ea((r,s)=>t(r,s,i)):H,Es(1),e?Bg(n):nj(()=>new Fg))}function D8(t,n){return Y(n)?Ne(t,n,1):Ne(t,1)}function L4(t){return Ue((n,e)=>{let s,i=null,r=!1;i=n.subscribe(Ze(e,void 0,void 0,a=>{s=lt(t(a,L4(t)(n))),i?(i.unsubscribe(),i=null,s.subscribe(e)):r=!0})),r&&(i.unsubscribe(),i=null,s.subscribe(e))})}function qM(t){return t<=0?()=>pt:Ue((n,e)=>{let i=[];n.subscribe(Ze(e,r=>{i.push(r),t<i.length&&i.shift()},()=>{for(const r of i)e.next(r);e.complete()},void 0,()=>{i=null}))})}function GM(t){return Ue((n,e)=>{try{n.subscribe(e)}finally{e.add(t)}})}const mi="primary",N8=Symbol("RouteTitle");class eye{constructor(n){this.params=n||{}}has(n){return Object.prototype.hasOwnProperty.call(this.params,n)}get(n){if(this.has(n)){const e=this.params[n];return Array.isArray(e)?e[0]:e}return null}getAll(n){if(this.has(n)){const e=this.params[n];return Array.isArray(e)?e:[e]}return[]}get keys(){return Object.keys(this.params)}}function ud(t){return new eye(t)}function tye(t,n,e){const i=e.path.split("/");if(i.length>t.length||"full"===e.pathMatch&&(n.hasChildren()||i.length<t.length))return null;const r={};for(let s=0;s<i.length;s++){const a=i[s],o=t[s];if(a.startsWith(":"))r[a.substring(1)]=o;else if(a!==o.path)return null}return{consumed:t.slice(0,i.length),posParams:r}}function xc(t,n){const e=t?Object.keys(t):void 0,i=n?Object.keys(n):void 0;if(!e||!i||e.length!=i.length)return!1;let r;for(let s=0;s<e.length;s++)if(r=e[s],!ij(t[r],n[r]))return!1;return!0}function ij(t,n){if(Array.isArray(t)&&Array.isArray(n)){if(t.length!==n.length)return!1;const e=[...t].sort(),i=[...n].sort();return e.every((r,s)=>i[s]===r)}return t===n}function rj(t){return t.length>0?t[t.length-1]:null}function V3(t){return J$(t)?t:$f(t)?ti(Promise.resolve(t)):ln(t)}const iye={exact:function oj(t,n,e){if(!P4(t.segments,n.segments)||!Ug(t.segments,n.segments,e)||t.numberOfChildren!==n.numberOfChildren)return!1;for(const i in n.children)if(!t.children[i]||!oj(t.children[i],n.children[i],e))return!1;return!0},subset:cj},sj={exact:function rye(t,n){return xc(t,n)},subset:function sye(t,n){return Object.keys(n).length<=Object.keys(t).length&&Object.keys(n).every(e=>ij(t[e],n[e]))},ignored:()=>!0};function aj(t,n,e){return iye[e.paths](t.root,n.root,e.matrixParams)&&sj[e.queryParams](t.queryParams,n.queryParams)&&!("exact"===e.fragment&&t.fragment!==n.fragment)}function cj(t,n,e){return lj(t,n,n.segments,e)}function lj(t,n,e,i){if(t.segments.length>e.length){const r=t.segments.slice(0,e.length);return!(!P4(r,e)||n.hasChildren()||!Ug(r,e,i))}if(t.segments.length===e.length){if(!P4(t.segments,e)||!Ug(t.segments,e,i))return!1;for(const r in n.children)if(!t.children[r]||!cj(t.children[r],n.children[r],i))return!1;return!0}{const r=e.slice(0,t.segments.length),s=e.slice(t.segments.length);return!!(P4(t.segments,r)&&Ug(t.segments,r,i)&&t.children[mi])&&lj(t.children[mi],n,s,i)}}function Ug(t,n,e){return n.every((i,r)=>sj[e](t[r].parameters,i.parameters))}class dd{constructor(n=new _r([],{}),e={},i=null){this.root=n,this.queryParams=e,this.fragment=i}get queryParamMap(){return this._queryParamMap||(this._queryParamMap=ud(this.queryParams)),this._queryParamMap}toString(){return cye.serialize(this)}}class _r{constructor(n,e){this.segments=n,this.children=e,this.parent=null,Object.values(e).forEach(i=>i.parent=this)}hasChildren(){return this.numberOfChildren>0}get numberOfChildren(){return Object.keys(this.children).length}toString(){return $g(this)}}class R8{constructor(n,e){this.path=n,this.parameters=e}get parameterMap(){return this._parameterMap||(this._parameterMap=ud(this.parameters)),this._parameterMap}toString(){return fj(this)}}function P4(t,n){return t.length===n.length&&t.every((e,i)=>e.path===n[i].path)}let L8=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return new ZM},providedIn:"root"})}return t})();class ZM{parse(n){const e=new _ye(n);return new dd(e.parseRootSegment(),e.parseQueryParams(),e.parseFragment())}serialize(n){const e=`/${P8(n.root,!0)}`,i=function dye(t){const n=Object.keys(t).map(e=>{const i=t[e];return Array.isArray(i)?i.map(r=>`${jg(e)}=${jg(r)}`).join("&"):`${jg(e)}=${jg(i)}`}).filter(e=>!!e);return n.length?`?${n.join("&")}`:""}(n.queryParams);return`${e}${i}${"string"==typeof n.fragment?`#${function lye(t){return encodeURI(t)}(n.fragment)}`:""}`}}const cye=new ZM;function $g(t){return t.segments.map(n=>fj(n)).join("/")}function P8(t,n){if(!t.hasChildren())return $g(t);if(n){const e=t.children[mi]?P8(t.children[mi],!1):"",i=[];return Object.entries(t.children).forEach(([r,s])=>{r!==mi&&i.push(`${r}:${P8(s,!1)}`)}),i.length>0?`${e}(${i.join("//")})`:e}{const e=function oye(t,n){let e=[];return Object.entries(t.children).forEach(([i,r])=>{i===mi&&(e=e.concat(n(r,i)))}),Object.entries(t.children).forEach(([i,r])=>{i!==mi&&(e=e.concat(n(r,i)))}),e}(t,(i,r)=>r===mi?[P8(t.children[mi],!1)]:[`${r}:${P8(i,!1)}`]);return 1===Object.keys(t.children).length&&null!=t.children[mi]?`${$g(t)}/${e[0]}`:`${$g(t)}/(${e.join("//")})`}}function uj(t){return encodeURIComponent(t).replace(/%40/g,"@").replace(/%3A/gi,":").replace(/%24/g,"$").replace(/%2C/gi,",")}function jg(t){return uj(t).replace(/%3B/gi,";")}function YM(t){return uj(t).replace(/\(/g,"%28").replace(/\)/g,"%29").replace(/%26/gi,"&")}function Wg(t){return decodeURIComponent(t)}function dj(t){return Wg(t.replace(/\+/g,"%20"))}function fj(t){return`${YM(t.path)}${function uye(t){return Object.keys(t).map(n=>`;${YM(n)}=${YM(t[n])}`).join("")}(t.parameters)}`}const fye=/^[^\/()?;#]+/;function KM(t){const n=t.match(fye);return n?n[0]:""}const hye=/^[^\/()?;=#]+/,mye=/^[^=?&#]+/,vye=/^[^&#]+/;class _ye{constructor(n){this.url=n,this.remaining=n}parseRootSegment(){return this.consumeOptional("/"),""===this.remaining||this.peekStartsWith("?")||this.peekStartsWith("#")?new _r([],{}):new _r([],this.parseChildren())}parseQueryParams(){const n={};if(this.consumeOptional("?"))do{this.parseQueryParam(n)}while(this.consumeOptional("&"));return n}parseFragment(){return this.consumeOptional("#")?decodeURIComponent(this.remaining):null}parseChildren(){if(""===this.remaining)return{};this.consumeOptional("/");const n=[];for(this.peekStartsWith("(")||n.push(this.parseSegment());this.peekStartsWith("/")&&!this.peekStartsWith("//")&&!this.peekStartsWith("/(");)this.capture("/"),n.push(this.parseSegment());let e={};this.peekStartsWith("/(")&&(this.capture("/"),e=this.parseParens(!0));let i={};return this.peekStartsWith("(")&&(i=this.parseParens(!1)),(n.length>0||Object.keys(e).length>0)&&(i[mi]=new _r(n,e)),i}parseSegment(){const n=KM(this.remaining);if(""===n&&this.peekStartsWith(";"))throw new kt(4009,!1);return this.capture(n),new R8(Wg(n),this.parseMatrixParams())}parseMatrixParams(){const n={};for(;this.consumeOptional(";");)this.parseParam(n);return n}parseParam(n){const e=function pye(t){const n=t.match(hye);return n?n[0]:""}(this.remaining);if(!e)return;this.capture(e);let i="";if(this.consumeOptional("=")){const r=KM(this.remaining);r&&(i=r,this.capture(i))}n[Wg(e)]=Wg(i)}parseQueryParam(n){const e=function gye(t){const n=t.match(mye);return n?n[0]:""}(this.remaining);if(!e)return;this.capture(e);let i="";if(this.consumeOptional("=")){const a=function yye(t){const n=t.match(vye);return n?n[0]:""}(this.remaining);a&&(i=a,this.capture(i))}const r=dj(e),s=dj(i);if(n.hasOwnProperty(r)){let a=n[r];Array.isArray(a)||(a=[a],n[r]=a),a.push(s)}else n[r]=s}parseParens(n){const e={};for(this.capture("(");!this.consumeOptional(")")&&this.remaining.length>0;){const i=KM(this.remaining),r=this.remaining[i.length];if("/"!==r&&")"!==r&&";"!==r)throw new kt(4010,!1);let s;i.indexOf(":")>-1?(s=i.slice(0,i.indexOf(":")),this.capture(s),this.capture(":")):n&&(s=mi);const a=this.parseChildren();e[s]=1===Object.keys(a).length?a[mi]:new _r([],a),this.consumeOptional("//")}return e}peekStartsWith(n){return this.remaining.startsWith(n)}consumeOptional(n){return!!this.peekStartsWith(n)&&(this.remaining=this.remaining.substring(n.length),!0)}capture(n){if(!this.consumeOptional(n))throw new kt(4011,!1)}}function hj(t){return t.segments.length>0?new _r([],{[mi]:t}):t}function pj(t){const n={};for(const i of Object.keys(t.children)){const s=pj(t.children[i]);if(i===mi&&0===s.segments.length&&s.hasChildren())for(const[a,o]of Object.entries(s.children))n[a]=o;else(s.segments.length>0||s.hasChildren())&&(n[i]=s)}return function bye(t){if(1===t.numberOfChildren&&t.children[mi]){const n=t.children[mi];return new _r(t.segments.concat(n.segments),n.children)}return t}(new _r(t.segments,n))}function z4(t){return t instanceof dd}function mj(t){let n;const i=function e(s){const a={};for(const c of s.children){const l=e(c);a[c.outlet]=l}const o=new _r(s.url,a);return s===t&&(n=o),o}(t.root),r=hj(i);return n??r}function gj(t,n,e,i){let r=t;for(;r.parent;)r=r.parent;if(0===n.length)return XM(r,r,r,e,i);const s=function Cye(t){if("string"==typeof t[0]&&1===t.length&&"/"===t[0])return new yj(!0,0,t);let n=0,e=!1;const i=t.reduce((r,s,a)=>{if("object"==typeof s&&null!=s){if(s.outlets){const o={};return Object.entries(s.outlets).forEach(([c,l])=>{o[c]="string"==typeof l?l.split("/"):l}),[...r,{outlets:o}]}if(s.segmentPath)return[...r,s.segmentPath]}return"string"!=typeof s?[...r,s]:0===a?(s.split("/").forEach((o,c)=>{0==c&&"."===o||(0==c&&""===o?e=!0:".."===o?n++:""!=o&&r.push(o))}),r):[...r,s]},[]);return new yj(e,n,i)}(n);if(s.toRoot())return XM(r,r,new _r([],{}),e,i);const a=function xye(t,n,e){if(t.isAbsolute)return new Gg(n,!0,0);if(!e)return new Gg(n,!1,NaN);if(null===e.parent)return new Gg(e,!0,0);const i=qg(t.commands[0])?0:1;return function Tye(t,n,e){let i=t,r=n,s=e;for(;s>r;){if(s-=r,i=i.parent,!i)throw new kt(4005,!1);r=i.segments.length}return new Gg(i,!1,r-s)}(e,e.segments.length-1+i,t.numberOfDoubleDots)}(s,r,t),o=a.processChildren?O8(a.segmentGroup,a.index,s.commands):_j(a.segmentGroup,a.index,s.commands);return XM(r,a.segmentGroup,o,e,i)}function qg(t){return"object"==typeof t&&null!=t&&!t.outlets&&!t.segmentPath}function z8(t){return"object"==typeof t&&null!=t&&t.outlets}function XM(t,n,e,i,r){let a,s={};i&&Object.entries(i).forEach(([c,l])=>{s[c]=Array.isArray(l)?l.map(u=>`${u}`):`${l}`}),a=t===n?e:vj(t,n,e);const o=hj(pj(a));return new dd(o,s,r)}function vj(t,n,e){const i={};return Object.entries(t.children).forEach(([r,s])=>{i[r]=s===n?e:vj(s,n,e)}),new _r(t.segments,i)}class yj{constructor(n,e,i){if(this.isAbsolute=n,this.numberOfDoubleDots=e,this.commands=i,n&&i.length>0&&qg(i[0]))throw new kt(4003,!1);const r=i.find(z8);if(r&&r!==rj(i))throw new kt(4004,!1)}toRoot(){return this.isAbsolute&&1===this.commands.length&&"/"==this.commands[0]}}class Gg{constructor(n,e,i){this.segmentGroup=n,this.processChildren=e,this.index=i}}function _j(t,n,e){if(t||(t=new _r([],{})),0===t.segments.length&&t.hasChildren())return O8(t,n,e);const i=function kye(t,n,e){let i=0,r=n;const s={match:!1,pathIndex:0,commandIndex:0};for(;r<t.segments.length;){if(i>=e.length)return s;const a=t.segments[r],o=e[i];if(z8(o))break;const c=`${o}`,l=i<e.length-1?e[i+1]:null;if(r>0&&void 0===c)break;if(c&&l&&"object"==typeof l&&void 0===l.outlets){if(!wj(c,l,a))return s;i+=2}else{if(!wj(c,{},a))return s;i++}r++}return{match:!0,pathIndex:r,commandIndex:i}}(t,n,e),r=e.slice(i.commandIndex);if(i.match&&i.pathIndex<t.segments.length){const s=new _r(t.segments.slice(0,i.pathIndex),{});return s.children[mi]=new _r(t.segments.slice(i.pathIndex),t.children),O8(s,0,r)}return i.match&&0===r.length?new _r(t.segments,{}):i.match&&!t.hasChildren()?QM(t,n,e):i.match?O8(t,0,r):QM(t,n,e)}function O8(t,n,e){if(0===e.length)return new _r(t.segments,{});{const i=function Mye(t){return z8(t[0])?t[0].outlets:{[mi]:t}}(e),r={};if(Object.keys(i).some(s=>s!==mi)&&t.children[mi]&&1===t.numberOfChildren&&0===t.children[mi].segments.length){const s=O8(t.children[mi],n,e);return new _r(t.segments,s.children)}return Object.entries(i).forEach(([s,a])=>{"string"==typeof a&&(a=[a]),null!==a&&(r[s]=_j(t.children[s],n,a))}),Object.entries(t.children).forEach(([s,a])=>{void 0===i[s]&&(r[s]=a)}),new _r(t.segments,r)}}function QM(t,n,e){const i=t.segments.slice(0,n);let r=0;for(;r<e.length;){const s=e[r];if(z8(s)){const c=Sye(s.outlets);return new _r(i,c)}if(0===r&&qg(e[0])){i.push(new R8(t.segments[n].path,bj(e[0]))),r++;continue}const a=z8(s)?s.outlets[mi]:`${s}`,o=r<e.length-1?e[r+1]:null;a&&o&&qg(o)?(i.push(new R8(a,bj(o))),r+=2):(i.push(new R8(a,{})),r++)}return new _r(i,{})}function Sye(t){const n={};return Object.entries(t).forEach(([e,i])=>{"string"==typeof i&&(i=[i]),null!==i&&(n[e]=QM(new _r([],{}),0,i))}),n}function bj(t){const n={};return Object.entries(t).forEach(([e,i])=>n[e]=`${i}`),n}function wj(t,n,e){return t==e.path&&xc(n,e.parameters)}const H8="imperative";class Tc{constructor(n,e){this.id=n,this.url=e}}class Zg extends Tc{constructor(n,e,i="imperative",r=null){super(n,e),this.type=0,this.navigationTrigger=i,this.restoredState=r}toString(){return`NavigationStart(id: ${this.id}, url: '${this.url}')`}}class F3 extends Tc{constructor(n,e,i){super(n,e),this.urlAfterRedirects=i,this.type=1}toString(){return`NavigationEnd(id: ${this.id}, url: '${this.url}', urlAfterRedirects: '${this.urlAfterRedirects}')`}}class V8 extends Tc{constructor(n,e,i,r){super(n,e),this.reason=i,this.code=r,this.type=2}toString(){return`NavigationCancel(id: ${this.id}, url: '${this.url}')`}}class fd extends Tc{constructor(n,e,i,r){super(n,e),this.reason=i,this.code=r,this.type=16}}class Yg extends Tc{constructor(n,e,i,r){super(n,e),this.error=i,this.target=r,this.type=3}toString(){return`NavigationError(id: ${this.id}, url: '${this.url}', error: ${this.error})`}}class Cj extends Tc{constructor(n,e,i,r){super(n,e),this.urlAfterRedirects=i,this.state=r,this.type=4}toString(){return`RoutesRecognized(id: ${this.id}, url: '${this.url}', urlAfterRedirects: '${this.urlAfterRedirects}', state: ${this.state})`}}class Eye extends Tc{constructor(n,e,i,r){super(n,e),this.urlAfterRedirects=i,this.state=r,this.type=7}toString(){return`GuardsCheckStart(id: ${this.id}, url: '${this.url}', urlAfterRedirects: '${this.urlAfterRedirects}', state: ${this.state})`}}class Aye extends Tc{constructor(n,e,i,r,s){super(n,e),this.urlAfterRedirects=i,this.state=r,this.shouldActivate=s,this.type=8}toString(){return`GuardsCheckEnd(id: ${this.id}, url: '${this.url}', urlAfterRedirects: '${this.urlAfterRedirects}', state: ${this.state}, shouldActivate: ${this.shouldActivate})`}}class Iye extends Tc{constructor(n,e,i,r){super(n,e),this.urlAfterRedirects=i,this.state=r,this.type=5}toString(){return`ResolveStart(id: ${this.id}, url: '${this.url}', urlAfterRedirects: '${this.urlAfterRedirects}', state: ${this.state})`}}class Dye extends Tc{constructor(n,e,i,r){super(n,e),this.urlAfterRedirects=i,this.state=r,this.type=6}toString(){return`ResolveEnd(id: ${this.id}, url: '${this.url}', urlAfterRedirects: '${this.urlAfterRedirects}', state: ${this.state})`}}class Nye{constructor(n){this.route=n,this.type=9}toString(){return`RouteConfigLoadStart(path: ${this.route.path})`}}class Rye{constructor(n){this.route=n,this.type=10}toString(){return`RouteConfigLoadEnd(path: ${this.route.path})`}}class Lye{constructor(n){this.snapshot=n,this.type=11}toString(){return`ChildActivationStart(path: '${this.snapshot.routeConfig&&this.snapshot.routeConfig.path||""}')`}}class Pye{constructor(n){this.snapshot=n,this.type=12}toString(){return`ChildActivationEnd(path: '${this.snapshot.routeConfig&&this.snapshot.routeConfig.path||""}')`}}class zye{constructor(n){this.snapshot=n,this.type=13}toString(){return`ActivationStart(path: '${this.snapshot.routeConfig&&this.snapshot.routeConfig.path||""}')`}}class O4{constructor(n){this.snapshot=n,this.type=14}toString(){return`ActivationEnd(path: '${this.snapshot.routeConfig&&this.snapshot.routeConfig.path||""}')`}}class xj{constructor(n,e,i){this.routerEvent=n,this.position=e,this.anchor=i,this.type=15}toString(){return`Scroll(anchor: '${this.anchor}', position: '${this.position?`${this.position[0]}, ${this.position[1]}`:null}')`}}class JM{}class ek{constructor(n){this.url=n}}class Oye{constructor(){this.outlet=null,this.route=null,this.injector=null,this.children=new F8,this.attachRef=null}}let F8=(()=>{class t{constructor(){this.contexts=new Map}onChildOutletCreated(e,i){const r=this.getOrCreateContext(e);r.outlet=i,this.contexts.set(e,r)}onChildOutletDestroyed(e){const i=this.getContext(e);i&&(i.outlet=null,i.attachRef=null)}onOutletDeactivated(){const e=this.contexts;return this.contexts=new Map,e}onOutletReAttached(e){this.contexts=e}getOrCreateContext(e){let i=this.getContext(e);return i||(i=new Oye,this.contexts.set(e,i)),i}getContext(e){return this.contexts.get(e)||null}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();class Tj{constructor(n){this._root=n}get root(){return this._root.value}parent(n){const e=this.pathFromRoot(n);return e.length>1?e[e.length-2]:null}children(n){const e=tk(n,this._root);return e?e.children.map(i=>i.value):[]}firstChild(n){const e=tk(n,this._root);return e&&e.children.length>0?e.children[0].value:null}siblings(n){const e=nk(n,this._root);return e.length<2?[]:e[e.length-2].children.map(r=>r.value).filter(r=>r!==n)}pathFromRoot(n){return nk(n,this._root).map(e=>e.value)}}function tk(t,n){if(t===n.value)return n;for(const e of n.children){const i=tk(t,e);if(i)return i}return null}function nk(t,n){if(t===n.value)return[n];for(const e of n.children){const i=nk(t,e);if(i.length)return i.unshift(n),i}return[]}class xl{constructor(n,e){this.value=n,this.children=e}toString(){return`TreeNode(${this.value})`}}function hd(t){const n={};return t&&t.children.forEach(e=>n[e.value.outlet]=e),n}class Mj extends Tj{constructor(n,e){super(n),this.snapshot=e,ik(this,n)}toString(){return this.snapshot.toString()}}function kj(t,n){const e=function Hye(t,n){const a=new Kg([],{},{},"",{},mi,n,null,{});return new Ej("",new xl(a,[]))}(0,n),i=new Vn([new R8("",{})]),r=new Vn({}),s=new Vn({}),a=new Vn({}),o=new Vn(""),c=new lo(i,r,a,o,s,mi,n,e.root);return c.snapshot=e.root,new Mj(new xl(c,[]),e)}class lo{constructor(n,e,i,r,s,a,o,c){this.urlSubject=n,this.paramsSubject=e,this.queryParamsSubject=i,this.fragmentSubject=r,this.dataSubject=s,this.outlet=a,this.component=o,this._futureSnapshot=c,this.title=this.dataSubject?.pipe(Le(l=>l[N8]))??ln(void 0),this.url=n,this.params=e,this.queryParams=i,this.fragment=r,this.data=s}get routeConfig(){return this._futureSnapshot.routeConfig}get root(){return this._routerState.root}get parent(){return this._routerState.parent(this)}get firstChild(){return this._routerState.firstChild(this)}get children(){return this._routerState.children(this)}get pathFromRoot(){return this._routerState.pathFromRoot(this)}get paramMap(){return this._paramMap||(this._paramMap=this.params.pipe(Le(n=>ud(n)))),this._paramMap}get queryParamMap(){return this._queryParamMap||(this._queryParamMap=this.queryParams.pipe(Le(n=>ud(n)))),this._queryParamMap}toString(){return this.snapshot?this.snapshot.toString():`Future(${this._futureSnapshot})`}}function Sj(t,n="emptyOnly"){const e=t.pathFromRoot;let i=0;if("always"!==n)for(i=e.length-1;i>=1;){const r=e[i],s=e[i-1];if(r.routeConfig&&""===r.routeConfig.path)i--;else{if(s.component)break;i--}}return function Vye(t){return t.reduce((n,e)=>({params:{...n.params,...e.params},data:{...n.data,...e.data},resolve:{...e.data,...n.resolve,...e.routeConfig?.data,...e._resolvedData}}),{params:{},data:{},resolve:{}})}(e.slice(i))}class Kg{get title(){return this.data?.[N8]}constructor(n,e,i,r,s,a,o,c,l){this.url=n,this.params=e,this.queryParams=i,this.fragment=r,this.data=s,this.outlet=a,this.component=o,this.routeConfig=c,this._resolve=l}get root(){return this._routerState.root}get parent(){return this._routerState.parent(this)}get firstChild(){return this._routerState.firstChild(this)}get children(){return this._routerState.children(this)}get pathFromRoot(){return this._routerState.pathFromRoot(this)}get paramMap(){return this._paramMap||(this._paramMap=ud(this.params)),this._paramMap}get queryParamMap(){return this._queryParamMap||(this._queryParamMap=ud(this.queryParams)),this._queryParamMap}toString(){return`Route(url:'${this.url.map(i=>i.toString()).join("/")}', path:'${this.routeConfig?this.routeConfig.path:""}')`}}class Ej extends Tj{constructor(n,e){super(e),this.url=n,ik(this,e)}toString(){return Aj(this._root)}}function ik(t,n){n.value._routerState=t,n.children.forEach(e=>ik(t,e))}function Aj(t){const n=t.children.length>0?` { ${t.children.map(Aj).join(", ")} } `:"";return`${t.value}${n}`}function rk(t){if(t.snapshot){const n=t.snapshot,e=t._futureSnapshot;t.snapshot=e,xc(n.queryParams,e.queryParams)||t.queryParamsSubject.next(e.queryParams),n.fragment!==e.fragment&&t.fragmentSubject.next(e.fragment),xc(n.params,e.params)||t.paramsSubject.next(e.params),function nye(t,n){if(t.length!==n.length)return!1;for(let e=0;e<t.length;++e)if(!xc(t[e],n[e]))return!1;return!0}(n.url,e.url)||t.urlSubject.next(e.url),xc(n.data,e.data)||t.dataSubject.next(e.data)}else t.snapshot=t._futureSnapshot,t.dataSubject.next(t._futureSnapshot.data)}function sk(t,n){const e=xc(t.params,n.params)&&function aye(t,n){return P4(t,n)&&t.every((e,i)=>xc(e.parameters,n[i].parameters))}(t.url,n.url);return e&&!(!t.parent!=!n.parent)&&(!t.parent||sk(t.parent,n.parent))}let ak=(()=>{class t{constructor(){this.activated=null,this._activatedRoute=null,this.name=mi,this.activateEvents=new Ht,this.deactivateEvents=new Ht,this.attachEvents=new Ht,this.detachEvents=new Ht,this.parentContexts=Kt(F8),this.location=Kt(ga),this.changeDetector=Kt(Dr),this.environmentInjector=Kt(Ao),this.inputBinder=Kt(Xg,{optional:!0}),this.supportsBindingToComponentInputs=!0}get activatedComponentRef(){return this.activated}ngOnChanges(e){if(e.name){const{firstChange:i,previousValue:r}=e.name;if(i)return;this.isTrackedInParentContexts(r)&&(this.deactivate(),this.parentContexts.onChildOutletDestroyed(r)),this.initializeOutletWithName()}}ngOnDestroy(){this.isTrackedInParentContexts(this.name)&&this.parentContexts.onChildOutletDestroyed(this.name),this.inputBinder?.unsubscribeFromRouteData(this)}isTrackedInParentContexts(e){return this.parentContexts.getContext(e)?.outlet===this}ngOnInit(){this.initializeOutletWithName()}initializeOutletWithName(){if(this.parentContexts.onChildOutletCreated(this.name,this),this.activated)return;const e=this.parentContexts.getContext(this.name);e?.route&&(e.attachRef?this.attach(e.attachRef,e.route):this.activateWith(e.route,e.injector))}get isActivated(){return!!this.activated}get component(){if(!this.activated)throw new kt(4012,!1);return this.activated.instance}get activatedRoute(){if(!this.activated)throw new kt(4012,!1);return this._activatedRoute}get activatedRouteData(){return this._activatedRoute?this._activatedRoute.snapshot.data:{}}detach(){if(!this.activated)throw new kt(4012,!1);this.location.detach();const e=this.activated;return this.activated=null,this._activatedRoute=null,this.detachEvents.emit(e.instance),e}attach(e,i){this.activated=e,this._activatedRoute=i,this.location.insert(e.hostView),this.inputBinder?.bindActivatedRouteToOutletComponent(this),this.attachEvents.emit(e.instance)}deactivate(){if(this.activated){const e=this.component;this.activated.destroy(),this.activated=null,this._activatedRoute=null,this.deactivateEvents.emit(e)}}activateWith(e,i){if(this.isActivated)throw new kt(4013,!1);this._activatedRoute=e;const r=this.location,a=e.snapshot.component,o=this.parentContexts.getOrCreateContext(this.name).children,c=new Fye(e,o,r.injector);this.activated=r.createComponent(a,{index:r.length,injector:c,environmentInjector:i??this.environmentInjector}),this.changeDetector.markForCheck(),this.inputBinder?.bindActivatedRouteToOutletComponent(this),this.activateEvents.emit(this.activated.instance)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275dir=zt({type:t,selectors:[["router-outlet"]],inputs:{name:"name"},outputs:{activateEvents:"activate",deactivateEvents:"deactivate",attachEvents:"attach",detachEvents:"detach"},exportAs:["outlet"],standalone:!0,features:[Un]})}return t})();class Fye{constructor(n,e,i){this.route=n,this.childContexts=e,this.parent=i}get(n,e){return n===lo?this.route:n===F8?this.childContexts:this.parent.get(n,e)}}const Xg=new Jt("");let Ij=(()=>{class t{constructor(){this.outletDataSubscriptions=new Map}bindActivatedRouteToOutletComponent(e){this.unsubscribeFromRouteData(e),this.subscribeToRouteData(e)}unsubscribeFromRouteData(e){this.outletDataSubscriptions.get(e)?.unsubscribe(),this.outletDataSubscriptions.delete(e)}subscribeToRouteData(e){const{activatedRoute:i}=e,r=Vg([i.queryParams,i.params,i.data]).pipe(vi(([s,a,o],c)=>(o={...s,...a,...o},0===c?ln(o):Promise.resolve(o)))).subscribe(s=>{if(!e.isActivated||!e.activatedComponentRef||e.activatedRoute!==i||null===i.component)return void this.unsubscribeFromRouteData(e);const a=function qde(t){const n=Si(t);if(!n)return null;const e=new Of(n);return{get selector(){return e.selector},get type(){return e.componentType},get inputs(){return e.inputs},get outputs(){return e.outputs},get ngContentSelectors(){return e.ngContentSelectors},get isStandalone(){return n.standalone},get isSignal(){return n.signals}}}(i.component);if(a)for(const{templateName:o}of a.inputs)e.activatedComponentRef.setInput(o,s[o]);else this.unsubscribeFromRouteData(e)});this.outletDataSubscriptions.set(e,r)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();function B8(t,n,e){if(e&&t.shouldReuseRoute(n.value,e.value.snapshot)){const i=e.value;i._futureSnapshot=n.value;const r=function Uye(t,n,e){return n.children.map(i=>{for(const r of e.children)if(t.shouldReuseRoute(i.value,r.value.snapshot))return B8(t,i,r);return B8(t,i)})}(t,n,e);return new xl(i,r)}{if(t.shouldAttach(n.value)){const s=t.retrieve(n.value);if(null!==s){const a=s.route;return a.value._futureSnapshot=n.value,a.children=n.children.map(o=>B8(t,o)),a}}const i=function $ye(t){return new lo(new Vn(t.url),new Vn(t.params),new Vn(t.queryParams),new Vn(t.fragment),new Vn(t.data),t.outlet,t.component,t)}(n.value),r=n.children.map(s=>B8(t,s));return new xl(i,r)}}const ok="ngNavigationCancelingError";function Dj(t,n){const{redirectTo:e,navigationBehaviorOptions:i}=z4(n)?{redirectTo:n,navigationBehaviorOptions:void 0}:n,r=Nj(!1,0,n);return r.url=e,r.navigationBehaviorOptions=i,r}function Nj(t,n,e){const i=new Error("NavigationCancelingError: "+(t||""));return i[ok]=!0,i.cancellationCode=n,e&&(i.url=e),i}function Rj(t){return t&&t[ok]}let Lj=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275cmp=Nt({type:t,selectors:[["ng-component"]],standalone:!0,features:[Ro],decls:1,vars:0,template:function(i,r){1&i&&Se(0,"router-outlet")},dependencies:[ak],encapsulation:2})}return t})();function ck(t){const n=t.children&&t.children.map(ck),e=n?{...t,children:n}:{...t};return!e.component&&!e.loadComponent&&(n||e.loadChildren)&&e.outlet&&e.outlet!==mi&&(e.component=Lj),e}function U2(t){return t.outlet||mi}function U8(t){if(!t)return null;if(t.routeConfig?._injector)return t.routeConfig._injector;for(let n=t.parent;n;n=n.parent){const e=n.routeConfig;if(e?._loadedInjector)return e._loadedInjector;if(e?._injector)return e._injector}return null}class Xye{constructor(n,e,i,r,s){this.routeReuseStrategy=n,this.futureState=e,this.currState=i,this.forwardEvent=r,this.inputBindingEnabled=s}activate(n){const e=this.futureState._root,i=this.currState?this.currState._root:null;this.deactivateChildRoutes(e,i,n),rk(this.futureState.root),this.activateChildRoutes(e,i,n)}deactivateChildRoutes(n,e,i){const r=hd(e);n.children.forEach(s=>{const a=s.value.outlet;this.deactivateRoutes(s,r[a],i),delete r[a]}),Object.values(r).forEach(s=>{this.deactivateRouteAndItsChildren(s,i)})}deactivateRoutes(n,e,i){const r=n.value,s=e?e.value:null;if(r===s)if(r.component){const a=i.getContext(r.outlet);a&&this.deactivateChildRoutes(n,e,a.children)}else this.deactivateChildRoutes(n,e,i);else s&&this.deactivateRouteAndItsChildren(e,i)}deactivateRouteAndItsChildren(n,e){n.value.component&&this.routeReuseStrategy.shouldDetach(n.value.snapshot)?this.detachAndStoreRouteSubtree(n,e):this.deactivateRouteAndOutlet(n,e)}detachAndStoreRouteSubtree(n,e){const i=e.getContext(n.value.outlet),r=i&&n.value.component?i.children:e,s=hd(n);for(const a of Object.keys(s))this.deactivateRouteAndItsChildren(s[a],r);if(i&&i.outlet){const a=i.outlet.detach(),o=i.children.onOutletDeactivated();this.routeReuseStrategy.store(n.value.snapshot,{componentRef:a,route:n,contexts:o})}}deactivateRouteAndOutlet(n,e){const i=e.getContext(n.value.outlet),r=i&&n.value.component?i.children:e,s=hd(n);for(const a of Object.keys(s))this.deactivateRouteAndItsChildren(s[a],r);i&&(i.outlet&&(i.outlet.deactivate(),i.children.onOutletDeactivated()),i.attachRef=null,i.route=null)}activateChildRoutes(n,e,i){const r=hd(e);n.children.forEach(s=>{this.activateRoutes(s,r[s.value.outlet],i),this.forwardEvent(new O4(s.value.snapshot))}),n.children.length&&this.forwardEvent(new Pye(n.value.snapshot))}activateRoutes(n,e,i){const r=n.value,s=e?e.value:null;if(rk(r),r===s)if(r.component){const a=i.getOrCreateContext(r.outlet);this.activateChildRoutes(n,e,a.children)}else this.activateChildRoutes(n,e,i);else if(r.component){const a=i.getOrCreateContext(r.outlet);if(this.routeReuseStrategy.shouldAttach(r.snapshot)){const o=this.routeReuseStrategy.retrieve(r.snapshot);this.routeReuseStrategy.store(r.snapshot,null),a.children.onOutletReAttached(o.contexts),a.attachRef=o.componentRef,a.route=o.route.value,a.outlet&&a.outlet.attach(o.componentRef,o.route.value),rk(o.route.value),this.activateChildRoutes(n,null,a.children)}else{const o=U8(r.snapshot);a.attachRef=null,a.route=r,a.injector=o,a.outlet&&a.outlet.activateWith(r,a.injector),this.activateChildRoutes(n,null,a.children)}}else this.activateChildRoutes(n,null,i)}}class Pj{constructor(n){this.path=n,this.route=this.path[this.path.length-1]}}class Qg{constructor(n,e){this.component=n,this.route=e}}function Qye(t,n,e){const i=t._root;return $8(i,n?n._root:null,e,[i.value])}function pd(t,n){const e=Symbol(),i=n.get(t,e);return i===e?"function"!=typeof t||function ow(t){return null!==$u(t)}(t)?n.get(t):t:i}function $8(t,n,e,i,r={canDeactivateChecks:[],canActivateChecks:[]}){const s=hd(n);return t.children.forEach(a=>{(function e_e(t,n,e,i,r={canDeactivateChecks:[],canActivateChecks:[]}){const s=t.value,a=n?n.value:null,o=e?e.getContext(t.value.outlet):null;if(a&&s.routeConfig===a.routeConfig){const c=function t_e(t,n,e){if("function"==typeof e)return e(t,n);switch(e){case"pathParamsChange":return!P4(t.url,n.url);case"pathParamsOrQueryParamsChange":return!P4(t.url,n.url)||!xc(t.queryParams,n.queryParams);case"always":return!0;case"paramsOrQueryParamsChange":return!sk(t,n)||!xc(t.queryParams,n.queryParams);default:return!sk(t,n)}}(a,s,s.routeConfig.runGuardsAndResolvers);c?r.canActivateChecks.push(new Pj(i)):(s.data=a.data,s._resolvedData=a._resolvedData),$8(t,n,s.component?o?o.children:null:e,i,r),c&&o&&o.outlet&&o.outlet.isActivated&&r.canDeactivateChecks.push(new Qg(o.outlet.component,a))}else a&&j8(n,o,r),r.canActivateChecks.push(new Pj(i)),$8(t,null,s.component?o?o.children:null:e,i,r)})(a,s[a.value.outlet],e,i.concat([a.value]),r),delete s[a.value.outlet]}),Object.entries(s).forEach(([a,o])=>j8(o,e.getContext(a),r)),r}function j8(t,n,e){const i=hd(t),r=t.value;Object.entries(i).forEach(([s,a])=>{j8(a,r.component?n?n.children.getContext(s):null:n,e)}),e.canDeactivateChecks.push(new Qg(r.component&&n&&n.outlet&&n.outlet.isActivated?n.outlet.component:null,r))}function W8(t){return"function"==typeof t}function zj(t){return t instanceof Fg||"EmptyError"===t?.name}const Jg=Symbol("INITIAL_VALUE");function md(){return vi(t=>Vg(t.map(n=>n.pipe(Es(1),$T(Jg)))).pipe(Le(n=>{for(const e of n)if(!0!==e){if(e===Jg)return Jg;if(!1===e||e instanceof dd)return e}return!0}),ea(n=>n!==Jg),Es(1)))}function Oj(t){return function C(...t){return j(t)}(ta(n=>{if(z4(n))throw Dj(0,n)}),Le(n=>!0===n))}class ev{constructor(n){this.segmentGroup=n||null}}class Hj{constructor(n){this.urlTree=n}}function gd(t){return I8(new ev(t))}function Vj(t){return I8(new Hj(t))}class w_e{constructor(n,e){this.urlSerializer=n,this.urlTree=e}noMatchError(n){return new kt(4002,!1)}lineralizeSegments(n,e){let i=[],r=e.root;for(;;){if(i=i.concat(r.segments),0===r.numberOfChildren)return ln(i);if(r.numberOfChildren>1||!r.children[mi])return I8(new kt(4e3,!1));r=r.children[mi]}}applyRedirectCommands(n,e,i){return this.applyRedirectCreateUrlTree(e,this.urlSerializer.parse(e),n,i)}applyRedirectCreateUrlTree(n,e,i,r){const s=this.createSegmentGroup(n,e.root,i,r);return new dd(s,this.createQueryParams(e.queryParams,this.urlTree.queryParams),e.fragment)}createQueryParams(n,e){const i={};return Object.entries(n).forEach(([r,s])=>{if("string"==typeof s&&s.startsWith(":")){const o=s.substring(1);i[r]=e[o]}else i[r]=s}),i}createSegmentGroup(n,e,i,r){const s=this.createSegments(n,e.segments,i,r);let a={};return Object.entries(e.children).forEach(([o,c])=>{a[o]=this.createSegmentGroup(n,c,i,r)}),new _r(s,a)}createSegments(n,e,i,r){return e.map(s=>s.path.startsWith(":")?this.findPosParam(n,s,r):this.findOrReturn(s,i))}findPosParam(n,e,i){const r=i[e.path.substring(1)];if(!r)throw new kt(4001,!1);return r}findOrReturn(n,e){let i=0;for(const r of e){if(r.path===n.path)return e.splice(i),r;i++}return n}}const lk={matched:!1,consumedSegments:[],remainingSegments:[],parameters:{},positionalParamSegments:{}};function C_e(t,n,e,i,r){const s=uk(t,n,e);return s.matched?(i=function Wye(t,n){return t.providers&&!t._injector&&(t._injector=ux(t.providers,n,`Route: ${t.path}`)),t._injector??n}(n,i),function y_e(t,n,e,i){const r=n.canMatch;return r&&0!==r.length?ln(r.map(a=>{const o=pd(a,t);return V3(function o_e(t){return t&&W8(t.canMatch)}(o)?o.canMatch(n,e):t.runInContext(()=>o(n,e)))})).pipe(md(),Oj()):ln(!0)}(i,n,e).pipe(Le(a=>!0===a?s:{...lk}))):ln(s)}function uk(t,n,e){if(""===n.path)return"full"===n.pathMatch&&(t.hasChildren()||e.length>0)?{...lk}:{matched:!0,consumedSegments:[],remainingSegments:e,parameters:{},positionalParamSegments:{}};const r=(n.matcher||tye)(e,t,n);if(!r)return{...lk};const s={};Object.entries(r.posParams??{}).forEach(([o,c])=>{s[o]=c.path});const a=r.consumed.length>0?{...s,...r.consumed[r.consumed.length-1].parameters}:s;return{matched:!0,consumedSegments:r.consumed,remainingSegments:e.slice(r.consumed.length),parameters:a,positionalParamSegments:r.posParams??{}}}function Fj(t,n,e,i){return e.length>0&&function M_e(t,n,e){return e.some(i=>tv(t,n,i)&&U2(i)!==mi)}(t,e,i)?{segmentGroup:new _r(n,T_e(i,new _r(e,t.children))),slicedSegments:[]}:0===e.length&&function k_e(t,n,e){return e.some(i=>tv(t,n,i))}(t,e,i)?{segmentGroup:new _r(t.segments,x_e(t,0,e,i,t.children)),slicedSegments:e}:{segmentGroup:new _r(t.segments,t.children),slicedSegments:e}}function x_e(t,n,e,i,r){const s={};for(const a of i)if(tv(t,e,a)&&!r[U2(a)]){const o=new _r([],{});s[U2(a)]=o}return{...r,...s}}function T_e(t,n){const e={};e[mi]=n;for(const i of t)if(""===i.path&&U2(i)!==mi){const r=new _r([],{});e[U2(i)]=r}return e}function tv(t,n,e){return(!(t.hasChildren()||n.length>0)||"full"!==e.pathMatch)&&""===e.path}class I_e{constructor(n,e,i,r,s,a,o){this.injector=n,this.configLoader=e,this.rootComponentType=i,this.config=r,this.urlTree=s,this.paramsInheritanceStrategy=a,this.urlSerializer=o,this.allowRedirects=!0,this.applyRedirects=new w_e(this.urlSerializer,this.urlTree)}noMatchError(n){return new kt(4002,!1)}recognize(){const n=Fj(this.urlTree.root,[],[],this.config).segmentGroup;return this.processSegmentGroup(this.injector,this.config,n,mi).pipe(L4(e=>{if(e instanceof Hj)return this.allowRedirects=!1,this.urlTree=e.urlTree,this.match(e.urlTree);throw e instanceof ev?this.noMatchError(e):e}),Le(e=>{const i=new Kg([],Object.freeze({}),Object.freeze({...this.urlTree.queryParams}),this.urlTree.fragment,{},mi,this.rootComponentType,null,{}),r=new xl(i,e),s=new Ej("",r),a=function wye(t,n,e=null,i=null){return gj(mj(t),n,e,i)}(i,[],this.urlTree.queryParams,this.urlTree.fragment);return a.queryParams=this.urlTree.queryParams,s.url=this.urlSerializer.serialize(a),this.inheritParamsAndData(s._root),{state:s,tree:a}}))}match(n){return this.processSegmentGroup(this.injector,this.config,n.root,mi).pipe(L4(i=>{throw i instanceof ev?this.noMatchError(i):i}))}inheritParamsAndData(n){const e=n.value,i=Sj(e,this.paramsInheritanceStrategy);e.params=Object.freeze(i.params),e.data=Object.freeze(i.data),n.children.forEach(r=>this.inheritParamsAndData(r))}processSegmentGroup(n,e,i,r){return 0===i.segments.length&&i.hasChildren()?this.processChildren(n,e,i):this.processSegment(n,e,i,i.segments,r,!0)}processChildren(n,e,i){const r=[];for(const s of Object.keys(i.children))"primary"===s?r.unshift(s):r.push(s);return ti(r).pipe(D8(s=>{const a=i.children[s],o=function Yye(t,n){const e=t.filter(i=>U2(i)===n);return e.push(...t.filter(i=>U2(i)!==n)),e}(e,s);return this.processSegmentGroup(n,o,a,s)}),function Qve(t,n){return Ue(function Xve(t,n,e,i,r){return(s,a)=>{let o=e,c=n,l=0;s.subscribe(Ze(a,u=>{const d=l++;c=o?t(c,u,d):(o=!0,u),i&&a.next(c)},r&&(()=>{o&&a.next(c),a.complete()})))}}(t,n,arguments.length>=2,!0))}((s,a)=>(s.push(...a),s)),Bg(null),function Jve(t,n){const e=arguments.length>=2;return i=>i.pipe(t?ea((r,s)=>t(r,s,i)):H,qM(1),e?Bg(n):nj(()=>new Fg))}(),Ne(s=>{if(null===s)return gd(i);const a=Bj(s);return function D_e(t){t.sort((n,e)=>n.value.outlet===mi?-1:e.value.outlet===mi?1:n.value.outlet.localeCompare(e.value.outlet))}(a),ln(a)}))}processSegment(n,e,i,r,s,a){return ti(e).pipe(D8(o=>this.processSegmentAgainstRoute(o._injector??n,e,o,i,r,s,a).pipe(L4(c=>{if(c instanceof ev)return ln(null);throw c}))),R4(o=>!!o),L4(o=>{if(zj(o))return function E_e(t,n,e){return 0===n.length&&!t.children[e]}(i,r,s)?ln([]):gd(i);throw o}))}processSegmentAgainstRoute(n,e,i,r,s,a,o){return function S_e(t,n,e,i){return!!(U2(t)===i||i!==mi&&tv(n,e,t))&&("**"===t.path||uk(n,t,e).matched)}(i,r,s,a)?void 0===i.redirectTo?this.matchSegmentAgainstRoute(n,r,i,s,a,o):o&&this.allowRedirects?this.expandSegmentAgainstRouteUsingRedirect(n,r,e,i,s,a):gd(r):gd(r)}expandSegmentAgainstRouteUsingRedirect(n,e,i,r,s,a){return"**"===r.path?this.expandWildCardWithParamsAgainstRouteUsingRedirect(n,i,r,a):this.expandRegularSegmentAgainstRouteUsingRedirect(n,e,i,r,s,a)}expandWildCardWithParamsAgainstRouteUsingRedirect(n,e,i,r){const s=this.applyRedirects.applyRedirectCommands([],i.redirectTo,{});return i.redirectTo.startsWith("/")?Vj(s):this.applyRedirects.lineralizeSegments(i,s).pipe(Ne(a=>{const o=new _r(a,{});return this.processSegment(n,e,o,a,r,!1)}))}expandRegularSegmentAgainstRouteUsingRedirect(n,e,i,r,s,a){const{matched:o,consumedSegments:c,remainingSegments:l,positionalParamSegments:u}=uk(e,r,s);if(!o)return gd(e);const d=this.applyRedirects.applyRedirectCommands(c,r.redirectTo,u);return r.redirectTo.startsWith("/")?Vj(d):this.applyRedirects.lineralizeSegments(r,d).pipe(Ne(h=>this.processSegment(n,i,e,h.concat(l),a,!1)))}matchSegmentAgainstRoute(n,e,i,r,s,a){let o;if("**"===i.path){const c=r.length>0?rj(r).parameters:{};o=ln({snapshot:new Kg(r,c,Object.freeze({...this.urlTree.queryParams}),this.urlTree.fragment,Uj(i),U2(i),i.component??i._loadedComponent??null,i,$j(i)),consumedSegments:[],remainingSegments:[]}),e.children={}}else o=C_e(e,i,r,n).pipe(Le(({matched:c,consumedSegments:l,remainingSegments:u,parameters:d})=>c?{snapshot:new Kg(l,d,Object.freeze({...this.urlTree.queryParams}),this.urlTree.fragment,Uj(i),U2(i),i.component??i._loadedComponent??null,i,$j(i)),consumedSegments:l,remainingSegments:u}:null));return o.pipe(vi(c=>null===c?gd(e):this.getChildConfig(n=i._injector??n,i,r).pipe(vi(({routes:l})=>{const u=i._loadedInjector??n,{snapshot:d,consumedSegments:h,remainingSegments:y}=c,{segmentGroup:I,slicedSegments:D}=Fj(e,h,y,l);if(0===D.length&&I.hasChildren())return this.processChildren(u,l,I).pipe(Le(we=>null===we?null:[new xl(d,we)]));if(0===l.length&&0===D.length)return ln([new xl(d,[])]);const V=U2(i)===s;return this.processSegment(u,l,I,D,V?mi:s,!0).pipe(Le(we=>[new xl(d,we)]))}))))}getChildConfig(n,e,i){return e.children?ln({routes:e.children,injector:n}):e.loadChildren?void 0!==e._loadedRoutes?ln({routes:e._loadedRoutes,injector:e._loadedInjector}):function v_e(t,n,e,i){const r=n.canLoad;return void 0===r||0===r.length?ln(!0):ln(r.map(a=>{const o=pd(a,t);return V3(function i_e(t){return t&&W8(t.canLoad)}(o)?o.canLoad(n,e):t.runInContext(()=>o(n,e)))})).pipe(md(),Oj())}(n,e,i).pipe(Ne(r=>r?this.configLoader.loadChildren(n,e).pipe(ta(s=>{e._loadedRoutes=s.routes,e._loadedInjector=s.injector})):function b_e(t){return I8(Nj(!1,3))}())):ln({routes:[],injector:n})}}function N_e(t){const n=t.value.routeConfig;return n&&""===n.path}function Bj(t){const n=[],e=new Set;for(const i of t){if(!N_e(i)){n.push(i);continue}const r=n.find(s=>i.value.routeConfig===s.value.routeConfig);void 0!==r?(r.children.push(...i.children),e.add(r)):n.push(i)}for(const i of e){const r=Bj(i.children);n.push(new xl(i.value,r))}return n.filter(i=>!e.has(i))}function Uj(t){return t.data||{}}function $j(t){return t.resolve||{}}function L_e(t,n){return Ne(e=>{const{targetSnapshot:i,guards:{canActivateChecks:r}}=e;if(!r.length)return ln(e);let s=0;return ti(r).pipe(D8(a=>function P_e(t,n,e,i){const r=t.routeConfig,s=t._resolve;return void 0!==r?.title&&!jj(r)&&(s[N8]=r.title),function z_e(t,n,e,i){const r=function O_e(t){return[...Object.keys(t),...Object.getOwnPropertySymbols(t)]}(t);if(0===r.length)return ln({});const s={};return ti(r).pipe(Ne(a=>function H_e(t,n,e,i){const r=U8(n)??i,s=pd(t,r);return V3(s.resolve?s.resolve(n,e):r.runInContext(()=>s(n,e)))}(t[a],n,e,i).pipe(R4(),ta(o=>{s[a]=o}))),qM(1),function RB(t){return Le(()=>t)}(s),L4(a=>zj(a)?pt:I8(a)))}(s,t,n,i).pipe(Le(a=>(t._resolvedData=a,t.data=Sj(t,e).resolve,r&&jj(r)&&(t.data[N8]=r.title),null)))}(a.route,i,t,n)),ta(()=>s++),qM(1),Ne(a=>s===r.length?ln(e):pt))})}function jj(t){return"string"==typeof t.title||null===t.title}function dk(t){return vi(n=>{const e=t(n);return e?ti(e).pipe(Le(()=>n)):ln(n)})}const vd=new Jt("ROUTES");let fk=(()=>{class t{constructor(){this.componentLoaders=new WeakMap,this.childrenLoaders=new WeakMap,this.compiler=Kt(KH)}loadComponent(e){if(this.componentLoaders.get(e))return this.componentLoaders.get(e);if(e._loadedComponent)return ln(e._loadedComponent);this.onLoadStartListener&&this.onLoadStartListener(e);const i=V3(e.loadComponent()).pipe(Le(Wj),ta(s=>{this.onLoadEndListener&&this.onLoadEndListener(e),e._loadedComponent=s}),GM(()=>{this.componentLoaders.delete(e)})),r=new WM(i,()=>new U).pipe(jM());return this.componentLoaders.set(e,r),r}loadChildren(e,i){if(this.childrenLoaders.get(i))return this.childrenLoaders.get(i);if(i._loadedRoutes)return ln({routes:i._loadedRoutes,injector:i._loadedInjector});this.onLoadStartListener&&this.onLoadStartListener(i);const s=function V_e(t,n,e,i){return V3(t.loadChildren()).pipe(Le(Wj),Ne(r=>r instanceof sH||Array.isArray(r)?ln(r):ti(n.compileModuleAsync(r))),Le(r=>{i&&i(t);let s,a,o=!1;return Array.isArray(r)?(a=r,!0):(s=r.create(e).injector,a=s.get(vd,[],{optional:!0,self:!0}).flat()),{routes:a.map(ck),injector:s}}))}(i,this.compiler,e,this.onLoadEndListener).pipe(GM(()=>{this.childrenLoaders.delete(i)})),a=new WM(s,()=>new U).pipe(jM());return this.childrenLoaders.set(i,a),a}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();function Wj(t){return function F_e(t){return t&&"object"==typeof t&&"default"in t}(t)?t.default:t}let nv=(()=>{class t{get hasRequestedNavigation(){return 0!==this.navigationId}constructor(){this.currentNavigation=null,this.currentTransition=null,this.lastSuccessfulNavigation=null,this.events=new U,this.transitionAbortSubject=new U,this.configLoader=Kt(fk),this.environmentInjector=Kt(Ao),this.urlSerializer=Kt(L8),this.rootContexts=Kt(F8),this.inputBindingEnabled=null!==Kt(Xg,{optional:!0}),this.navigationId=0,this.afterPreactivation=()=>ln(void 0),this.rootComponentType=null,this.configLoader.onLoadEndListener=r=>this.events.next(new Rye(r)),this.configLoader.onLoadStartListener=r=>this.events.next(new Nye(r))}complete(){this.transitions?.complete()}handleNavigationRequest(e){const i=++this.navigationId;this.transitions?.next({...this.transitions.value,...e,id:i})}setupNavigations(e,i,r){return this.transitions=new Vn({id:0,currentUrlTree:i,currentRawUrl:i,currentBrowserUrl:i,extractedUrl:e.urlHandlingStrategy.extract(i),urlAfterRedirects:e.urlHandlingStrategy.extract(i),rawUrl:i,extras:{},resolve:null,reject:null,promise:Promise.resolve(!0),source:H8,restoredState:null,currentSnapshot:r.snapshot,targetSnapshot:null,currentRouterState:r,targetRouterState:null,guards:{canActivateChecks:[],canDeactivateChecks:[]},guardsResult:null}),this.transitions.pipe(ea(s=>0!==s.id),Le(s=>({...s,extractedUrl:e.urlHandlingStrategy.extract(s.rawUrl)})),vi(s=>{this.currentTransition=s;let a=!1,o=!1;return ln(s).pipe(ta(c=>{this.currentNavigation={id:c.id,initialUrl:c.rawUrl,extractedUrl:c.extractedUrl,trigger:c.source,extras:c.extras,previousNavigation:this.lastSuccessfulNavigation?{...this.lastSuccessfulNavigation,previousNavigation:null}:null}}),vi(c=>{const l=c.currentBrowserUrl.toString(),u=!e.navigated||c.extractedUrl.toString()!==l||l!==c.currentUrlTree.toString();if(!u&&"reload"!==(c.extras.onSameUrlNavigation??e.onSameUrlNavigation)){const h="";return this.events.next(new fd(c.id,this.urlSerializer.serialize(c.rawUrl),h,0)),c.resolve(null),pt}if(e.urlHandlingStrategy.shouldProcessUrl(c.rawUrl))return ln(c).pipe(vi(h=>{const y=this.transitions?.getValue();return this.events.next(new Zg(h.id,this.urlSerializer.serialize(h.extractedUrl),h.source,h.restoredState)),y!==this.transitions?.getValue()?pt:Promise.resolve(h)}),function R_e(t,n,e,i,r,s){return Ne(a=>function A_e(t,n,e,i,r,s,a="emptyOnly"){return new I_e(t,n,e,i,r,a,s).recognize()}(t,n,e,i,a.extractedUrl,r,s).pipe(Le(({state:o,tree:c})=>({...a,targetSnapshot:o,urlAfterRedirects:c}))))}(this.environmentInjector,this.configLoader,this.rootComponentType,e.config,this.urlSerializer,e.paramsInheritanceStrategy),ta(h=>{s.targetSnapshot=h.targetSnapshot,s.urlAfterRedirects=h.urlAfterRedirects,this.currentNavigation={...this.currentNavigation,finalUrl:h.urlAfterRedirects};const y=new Cj(h.id,this.urlSerializer.serialize(h.extractedUrl),this.urlSerializer.serialize(h.urlAfterRedirects),h.targetSnapshot);this.events.next(y)}));if(u&&e.urlHandlingStrategy.shouldProcessUrl(c.currentRawUrl)){const{id:h,extractedUrl:y,source:I,restoredState:D,extras:V}=c,we=new Zg(h,this.urlSerializer.serialize(y),I,D);this.events.next(we);const Ce=kj(0,this.rootComponentType).snapshot;return this.currentTransition=s={...c,targetSnapshot:Ce,urlAfterRedirects:y,extras:{...V,skipLocationChange:!1,replaceUrl:!1}},ln(s)}{const h="";return this.events.next(new fd(c.id,this.urlSerializer.serialize(c.extractedUrl),h,1)),c.resolve(null),pt}}),ta(c=>{const l=new Eye(c.id,this.urlSerializer.serialize(c.extractedUrl),this.urlSerializer.serialize(c.urlAfterRedirects),c.targetSnapshot);this.events.next(l)}),Le(c=>(this.currentTransition=s={...c,guards:Qye(c.targetSnapshot,c.currentSnapshot,this.rootContexts)},s)),function l_e(t,n){return Ne(e=>{const{targetSnapshot:i,currentSnapshot:r,guards:{canActivateChecks:s,canDeactivateChecks:a}}=e;return 0===a.length&&0===s.length?ln({...e,guardsResult:!0}):function u_e(t,n,e,i){return ti(t).pipe(Ne(r=>function g_e(t,n,e,i,r){const s=n&&n.routeConfig?n.routeConfig.canDeactivate:null;return s&&0!==s.length?ln(s.map(o=>{const c=U8(n)??r,l=pd(o,c);return V3(function a_e(t){return t&&W8(t.canDeactivate)}(l)?l.canDeactivate(t,n,e,i):c.runInContext(()=>l(t,n,e,i))).pipe(R4())})).pipe(md()):ln(!0)}(r.component,r.route,e,n,i)),R4(r=>!0!==r,!0))}(a,i,r,t).pipe(Ne(o=>o&&function n_e(t){return"boolean"==typeof t}(o)?function d_e(t,n,e,i){return ti(n).pipe(D8(r=>X6(function h_e(t,n){return null!==t&&n&&n(new Lye(t)),ln(!0)}(r.route.parent,i),function f_e(t,n){return null!==t&&n&&n(new zye(t)),ln(!0)}(r.route,i),function m_e(t,n,e){const i=n[n.length-1],s=n.slice(0,n.length-1).reverse().map(a=>function Jye(t){const n=t.routeConfig?t.routeConfig.canActivateChild:null;return n&&0!==n.length?{node:t,guards:n}:null}(a)).filter(a=>null!==a).map(a=>tj(()=>ln(a.guards.map(c=>{const l=U8(a.node)??e,u=pd(c,l);return V3(function s_e(t){return t&&W8(t.canActivateChild)}(u)?u.canActivateChild(i,t):l.runInContext(()=>u(i,t))).pipe(R4())})).pipe(md())));return ln(s).pipe(md())}(t,r.path,e),function p_e(t,n,e){const i=n.routeConfig?n.routeConfig.canActivate:null;if(!i||0===i.length)return ln(!0);const r=i.map(s=>tj(()=>{const a=U8(n)??e,o=pd(s,a);return V3(function r_e(t){return t&&W8(t.canActivate)}(o)?o.canActivate(n,t):a.runInContext(()=>o(n,t))).pipe(R4())}));return ln(r).pipe(md())}(t,r.route,e))),R4(r=>!0!==r,!0))}(i,s,t,n):ln(o)),Le(o=>({...e,guardsResult:o})))})}(this.environmentInjector,c=>this.events.next(c)),ta(c=>{if(s.guardsResult=c.guardsResult,z4(c.guardsResult))throw Dj(0,c.guardsResult);const l=new Aye(c.id,this.urlSerializer.serialize(c.extractedUrl),this.urlSerializer.serialize(c.urlAfterRedirects),c.targetSnapshot,!!c.guardsResult);this.events.next(l)}),ea(c=>!!c.guardsResult||(this.cancelNavigationTransition(c,"",3),!1)),dk(c=>{if(c.guards.canActivateChecks.length)return ln(c).pipe(ta(l=>{const u=new Iye(l.id,this.urlSerializer.serialize(l.extractedUrl),this.urlSerializer.serialize(l.urlAfterRedirects),l.targetSnapshot);this.events.next(u)}),vi(l=>{let u=!1;return ln(l).pipe(L_e(e.paramsInheritanceStrategy,this.environmentInjector),ta({next:()=>u=!0,complete:()=>{u||this.cancelNavigationTransition(l,"",2)}}))}),ta(l=>{const u=new Dye(l.id,this.urlSerializer.serialize(l.extractedUrl),this.urlSerializer.serialize(l.urlAfterRedirects),l.targetSnapshot);this.events.next(u)}))}),dk(c=>{const l=u=>{const d=[];u.routeConfig?.loadComponent&&!u.routeConfig._loadedComponent&&d.push(this.configLoader.loadComponent(u.routeConfig).pipe(ta(h=>{u.component=h}),Le(()=>{})));for(const h of u.children)d.push(...l(h));return d};return Vg(l(c.targetSnapshot.root)).pipe(Bg(),Es(1))}),dk(()=>this.afterPreactivation()),Le(c=>{const l=function Bye(t,n,e){const i=B8(t,n._root,e?e._root:void 0);return new Mj(i,n)}(e.routeReuseStrategy,c.targetSnapshot,c.currentRouterState);return this.currentTransition=s={...c,targetRouterState:l},s}),ta(()=>{this.events.next(new JM)}),((t,n,e,i)=>Le(r=>(new Xye(n,r.targetRouterState,r.currentRouterState,e,i).activate(t),r)))(this.rootContexts,e.routeReuseStrategy,c=>this.events.next(c),this.inputBindingEnabled),Es(1),ta({next:c=>{a=!0,this.lastSuccessfulNavigation=this.currentNavigation,this.events.next(new F3(c.id,this.urlSerializer.serialize(c.extractedUrl),this.urlSerializer.serialize(c.urlAfterRedirects))),e.titleStrategy?.updateTitle(c.targetRouterState.snapshot),c.resolve(!0)},complete:()=>{a=!0}}),yr(this.transitionAbortSubject.pipe(ta(c=>{throw c}))),GM(()=>{a||o||this.cancelNavigationTransition(s,"",1),this.currentNavigation?.id===s.id&&(this.currentNavigation=null)}),L4(c=>{if(o=!0,Rj(c))this.events.next(new V8(s.id,this.urlSerializer.serialize(s.extractedUrl),c.message,c.cancellationCode)),function jye(t){return Rj(t)&&z4(t.url)}(c)?this.events.next(new ek(c.url)):s.resolve(!1);else{this.events.next(new Yg(s.id,this.urlSerializer.serialize(s.extractedUrl),c,s.targetSnapshot??void 0));try{s.resolve(e.errorHandler(c))}catch(l){s.reject(l)}}return pt}))}))}cancelNavigationTransition(e,i,r){const s=new V8(e.id,this.urlSerializer.serialize(e.extractedUrl),i,r);this.events.next(s),e.resolve(!1)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();function qj(t){return t!==H8}let Gj=(()=>{class t{buildTitle(e){let i,r=e.root;for(;void 0!==r;)i=this.getResolvedTitleForRoute(r)??i,r=r.children.find(s=>s.outlet===mi);return i}getResolvedTitleForRoute(e){return e.data[N8]}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return Kt(B_e)},providedIn:"root"})}return t})(),B_e=(()=>{class t extends Gj{constructor(e){super(),this.title=e}updateTitle(e){const i=this.buildTitle(e);void 0!==i&&this.title.setTitle(i)}static#e=this.\u0275fac=function(i){return new(i||t)(gt(yF))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),U_e=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return Kt(j_e)},providedIn:"root"})}return t})();class $_e{shouldDetach(n){return!1}store(n,e){}shouldAttach(n){return!1}retrieve(n){return null}shouldReuseRoute(n,e){return n.routeConfig===e.routeConfig}}let j_e=(()=>{class t extends $_e{static#e=this.\u0275fac=function(){let e;return function(r){return(e||(e=Di(t)))(r||t)}}();static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();const iv=new Jt("",{providedIn:"root",factory:()=>({})});let W_e=(()=>{class t{static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:function(){return Kt(q_e)},providedIn:"root"})}return t})(),q_e=(()=>{class t{shouldProcessUrl(e){return!0}extract(e){return e}merge(e,i){return e}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();var q8=function(t){return t[t.COMPLETE=0]="COMPLETE",t[t.FAILED=1]="FAILED",t[t.REDIRECTING=2]="REDIRECTING",t}(q8||{});function Zj(t,n){t.events.pipe(ea(e=>e instanceof F3||e instanceof V8||e instanceof Yg||e instanceof fd),Le(e=>e instanceof F3||e instanceof fd?q8.COMPLETE:e instanceof V8&&(0===e.code||1===e.code)?q8.REDIRECTING:q8.FAILED),ea(e=>e!==q8.REDIRECTING),Es(1)).subscribe(()=>{n()})}function G_e(t){throw t}function Z_e(t,n,e){return n.parse("/")}const Y_e={paths:"exact",fragment:"ignored",matrixParams:"ignored",queryParams:"exact"},K_e={paths:"subset",fragment:"ignored",matrixParams:"ignored",queryParams:"subset"};let Br=(()=>{class t{get navigationId(){return this.navigationTransitions.navigationId}get browserPageId(){return"computed"!==this.canceledNavigationResolution?this.currentPageId:this.location.getState()?.\u0275routerPageId??this.currentPageId}get events(){return this._events}constructor(){this.disposed=!1,this.currentPageId=0,this.console=Kt(ZH),this.isNgZoneEnabled=!1,this._events=new U,this.options=Kt(iv,{optional:!0})||{},this.pendingTasks=Kt(YH),this.errorHandler=this.options.errorHandler||G_e,this.malformedUriErrorHandler=this.options.malformedUriErrorHandler||Z_e,this.navigated=!1,this.lastSuccessfulId=-1,this.urlHandlingStrategy=Kt(W_e),this.routeReuseStrategy=Kt(U_e),this.titleStrategy=Kt(Gj),this.onSameUrlNavigation=this.options.onSameUrlNavigation||"ignore",this.paramsInheritanceStrategy=this.options.paramsInheritanceStrategy||"emptyOnly",this.urlUpdateStrategy=this.options.urlUpdateStrategy||"deferred",this.canceledNavigationResolution=this.options.canceledNavigationResolution||"replace",this.config=Kt(vd,{optional:!0})?.flat()??[],this.navigationTransitions=Kt(nv),this.urlSerializer=Kt(L8),this.location=Kt($x),this.componentInputBindingEnabled=!!Kt(Xg,{optional:!0}),this.eventsSubscription=new w,this.isNgZoneEnabled=Kt(Xn)instanceof Xn&&Xn.isInAngularZone(),this.resetConfig(this.config),this.currentUrlTree=new dd,this.rawUrlTree=this.currentUrlTree,this.browserUrlTree=this.currentUrlTree,this.routerState=kj(0,null),this.navigationTransitions.setupNavigations(this,this.currentUrlTree,this.routerState).subscribe(e=>{this.lastSuccessfulId=e.id,this.currentPageId=this.browserPageId},e=>{this.console.warn(`Unhandled Navigation Error: ${e}`)}),this.subscribeToNavigationEvents()}subscribeToNavigationEvents(){const e=this.navigationTransitions.events.subscribe(i=>{try{const{currentTransition:r}=this.navigationTransitions;if(null===r)return void(Yj(i)&&this._events.next(i));if(i instanceof Zg)qj(r.source)&&(this.browserUrlTree=r.extractedUrl);else if(i instanceof fd)this.rawUrlTree=r.rawUrl;else if(i instanceof Cj){if("eager"===this.urlUpdateStrategy){if(!r.extras.skipLocationChange){const s=this.urlHandlingStrategy.merge(r.urlAfterRedirects,r.rawUrl);this.setBrowserUrl(s,r)}this.browserUrlTree=r.urlAfterRedirects}}else if(i instanceof JM)this.currentUrlTree=r.urlAfterRedirects,this.rawUrlTree=this.urlHandlingStrategy.merge(r.urlAfterRedirects,r.rawUrl),this.routerState=r.targetRouterState,"deferred"===this.urlUpdateStrategy&&(r.extras.skipLocationChange||this.setBrowserUrl(this.rawUrlTree,r),this.browserUrlTree=r.urlAfterRedirects);else if(i instanceof V8)0!==i.code&&1!==i.code&&(this.navigated=!0),(3===i.code||2===i.code)&&this.restoreHistory(r);else if(i instanceof ek){const s=this.urlHandlingStrategy.merge(i.url,r.currentRawUrl),a={skipLocationChange:r.extras.skipLocationChange,replaceUrl:"eager"===this.urlUpdateStrategy||qj(r.source)};this.scheduleNavigation(s,H8,null,a,{resolve:r.resolve,reject:r.reject,promise:r.promise})}i instanceof Yg&&this.restoreHistory(r,!0),i instanceof F3&&(this.navigated=!0),Yj(i)&&this._events.next(i)}catch(r){this.navigationTransitions.transitionAbortSubject.next(r)}});this.eventsSubscription.add(e)}resetRootComponentType(e){this.routerState.root.component=e,this.navigationTransitions.rootComponentType=e}initialNavigation(){if(this.setUpLocationChangeListener(),!this.navigationTransitions.hasRequestedNavigation){const e=this.location.getState();this.navigateToSyncWithBrowser(this.location.path(!0),H8,e)}}setUpLocationChangeListener(){this.locationSubscription||(this.locationSubscription=this.location.subscribe(e=>{const i="popstate"===e.type?"popstate":"hashchange";"popstate"===i&&setTimeout(()=>{this.navigateToSyncWithBrowser(e.url,i,e.state)},0)}))}navigateToSyncWithBrowser(e,i,r){const s={replaceUrl:!0},a=r?.navigationId?r:null;if(r){const c={...r};delete c.navigationId,delete c.\u0275routerPageId,0!==Object.keys(c).length&&(s.state=c)}const o=this.parseUrl(e);this.scheduleNavigation(o,i,a,s)}get url(){return this.serializeUrl(this.currentUrlTree)}getCurrentNavigation(){return this.navigationTransitions.currentNavigation}get lastSuccessfulNavigation(){return this.navigationTransitions.lastSuccessfulNavigation}resetConfig(e){this.config=e.map(ck),this.navigated=!1,this.lastSuccessfulId=-1}ngOnDestroy(){this.dispose()}dispose(){this.navigationTransitions.complete(),this.locationSubscription&&(this.locationSubscription.unsubscribe(),this.locationSubscription=void 0),this.disposed=!0,this.eventsSubscription.unsubscribe()}createUrlTree(e,i={}){const{relativeTo:r,queryParams:s,fragment:a,queryParamsHandling:o,preserveFragment:c}=i,l=c?this.currentUrlTree.fragment:a;let d,u=null;switch(o){case"merge":u={...this.currentUrlTree.queryParams,...s};break;case"preserve":u=this.currentUrlTree.queryParams;break;default:u=s||null}null!==u&&(u=this.removeEmptyProps(u));try{d=mj(r?r.snapshot:this.routerState.snapshot.root)}catch{("string"!=typeof e[0]||!e[0].startsWith("/"))&&(e=[]),d=this.currentUrlTree.root}return gj(d,e,u,l??null)}navigateByUrl(e,i={skipLocationChange:!1}){const r=z4(e)?e:this.parseUrl(e),s=this.urlHandlingStrategy.merge(r,this.rawUrlTree);return this.scheduleNavigation(s,H8,null,i)}navigate(e,i={skipLocationChange:!1}){return function X_e(t){for(let n=0;n<t.length;n++)if(null==t[n])throw new kt(4008,!1)}(e),this.navigateByUrl(this.createUrlTree(e,i),i)}serializeUrl(e){return this.urlSerializer.serialize(e)}parseUrl(e){let i;try{i=this.urlSerializer.parse(e)}catch(r){i=this.malformedUriErrorHandler(r,this.urlSerializer,e)}return i}isActive(e,i){let r;if(r=!0===i?{...Y_e}:!1===i?{...K_e}:i,z4(e))return aj(this.currentUrlTree,e,r);const s=this.parseUrl(e);return aj(this.currentUrlTree,s,r)}removeEmptyProps(e){return Object.keys(e).reduce((i,r)=>{const s=e[r];return null!=s&&(i[r]=s),i},{})}scheduleNavigation(e,i,r,s,a){if(this.disposed)return Promise.resolve(!1);let o,c,l;a?(o=a.resolve,c=a.reject,l=a.promise):l=new Promise((d,h)=>{o=d,c=h});const u=this.pendingTasks.add();return Zj(this,()=>{queueMicrotask(()=>this.pendingTasks.remove(u))}),this.navigationTransitions.handleNavigationRequest({source:i,restoredState:r,currentUrlTree:this.currentUrlTree,currentRawUrl:this.currentUrlTree,currentBrowserUrl:this.browserUrlTree,rawUrl:e,extras:s,resolve:o,reject:c,promise:l,currentSnapshot:this.routerState.snapshot,currentRouterState:this.routerState}),l.catch(d=>Promise.reject(d))}setBrowserUrl(e,i){const r=this.urlSerializer.serialize(e);if(this.location.isCurrentPathEqualTo(r)||i.extras.replaceUrl){const a={...i.extras.state,...this.generateNgRouterState(i.id,this.browserPageId)};this.location.replaceState(r,"",a)}else{const s={...i.extras.state,...this.generateNgRouterState(i.id,this.browserPageId+1)};this.location.go(r,"",s)}}restoreHistory(e,i=!1){if("computed"===this.canceledNavigationResolution){const s=this.currentPageId-this.browserPageId;0!==s?this.location.historyGo(s):this.currentUrlTree===this.getCurrentNavigation()?.finalUrl&&0===s&&(this.resetState(e),this.browserUrlTree=e.currentUrlTree,this.resetUrlToCurrentUrlTree())}else"replace"===this.canceledNavigationResolution&&(i&&this.resetState(e),this.resetUrlToCurrentUrlTree())}resetState(e){this.routerState=e.currentRouterState,this.currentUrlTree=e.currentUrlTree,this.rawUrlTree=this.urlHandlingStrategy.merge(this.currentUrlTree,e.rawUrl)}resetUrlToCurrentUrlTree(){this.location.replaceState(this.urlSerializer.serialize(this.rawUrlTree),"",this.generateNgRouterState(this.lastSuccessfulId,this.currentPageId))}generateNgRouterState(e,i){return"computed"===this.canceledNavigationResolution?{navigationId:e,\u0275routerPageId:i}:{navigationId:e}}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();function Yj(t){return!(t instanceof JM||t instanceof ek)}let B3=(()=>{class t{constructor(e,i,r,s,a,o){this.router=e,this.route=i,this.tabIndexAttribute=r,this.renderer=s,this.el=a,this.locationStrategy=o,this.href=null,this.commands=null,this.onChanges=new U,this.preserveFragment=!1,this.skipLocationChange=!1,this.replaceUrl=!1;const c=a.nativeElement.tagName?.toLowerCase();this.isAnchorElement="a"===c||"area"===c,this.isAnchorElement?this.subscription=e.events.subscribe(l=>{l instanceof F3&&this.updateHref()}):this.setTabIndexIfNotOnNativeEl("0")}setTabIndexIfNotOnNativeEl(e){null!=this.tabIndexAttribute||this.isAnchorElement||this.applyAttributeValue("tabindex",e)}ngOnChanges(e){this.isAnchorElement&&this.updateHref(),this.onChanges.next(this)}set routerLink(e){null!=e?(this.commands=Array.isArray(e)?e:[e],this.setTabIndexIfNotOnNativeEl("0")):(this.commands=null,this.setTabIndexIfNotOnNativeEl(null))}onClick(e,i,r,s,a){return!!(null===this.urlTree||this.isAnchorElement&&(0!==e||i||r||s||a||"string"==typeof this.target&&"_self"!=this.target))||(this.router.navigateByUrl(this.urlTree,{skipLocationChange:this.skipLocationChange,replaceUrl:this.replaceUrl,state:this.state}),!this.isAnchorElement)}ngOnDestroy(){this.subscription?.unsubscribe()}updateHref(){this.href=null!==this.urlTree&&this.locationStrategy?this.locationStrategy?.prepareExternalUrl(this.router.serializeUrl(this.urlTree)):null;const e=null===this.href?null:function hP(t,n,e){return function xle(t,n){return"src"===n&&("embed"===t||"frame"===t||"iframe"===t||"media"===t||"script"===t)||"href"===n&&("base"===t||"link"===t)?fP:Fi}(n,e)(t)}(this.href,this.el.nativeElement.tagName.toLowerCase(),"href");this.applyAttributeValue("href",e)}applyAttributeValue(e,i){const r=this.renderer,s=this.el.nativeElement;null!==i?r.setAttribute(s,e,i):r.removeAttribute(s,e)}get urlTree(){return null===this.commands?null:this.router.createUrlTree(this.commands,{relativeTo:void 0!==this.relativeTo?this.relativeTo:this.route,queryParams:this.queryParams,fragment:this.fragment,queryParamsHandling:this.queryParamsHandling,preserveFragment:this.preserveFragment})}static#e=this.\u0275fac=function(i){return new(i||t)(Te(Br),Te(lo),k3("tabindex"),Te(Io),Te($n),Te(y4))};static#t=this.\u0275dir=zt({type:t,selectors:[["","routerLink",""]],hostVars:1,hostBindings:function(i,r){1&i&&Ee("click",function(a){return r.onClick(a.button,a.ctrlKey,a.shiftKey,a.altKey,a.metaKey)}),2&i&&pi("target",r.target)},inputs:{target:"target",queryParams:"queryParams",fragment:"fragment",queryParamsHandling:"queryParamsHandling",state:"state",relativeTo:"relativeTo",preserveFragment:["preserveFragment","preserveFragment",q6],skipLocationChange:["skipLocationChange","skipLocationChange",q6],replaceUrl:["replaceUrl","replaceUrl",q6],routerLink:"routerLink"},standalone:!0,features:[kz,Un]})}return t})();class Kj{}let ebe=(()=>{class t{constructor(e,i,r,s,a){this.router=e,this.injector=r,this.preloadingStrategy=s,this.loader=a}setUpPreloading(){this.subscription=this.router.events.pipe(ea(e=>e instanceof F3),D8(()=>this.preload())).subscribe(()=>{})}preload(){return this.processRoutes(this.injector,this.router.config)}ngOnDestroy(){this.subscription&&this.subscription.unsubscribe()}processRoutes(e,i){const r=[];for(const s of i){s.providers&&!s._injector&&(s._injector=ux(s.providers,e,`Route: ${s.path}`));const a=s._injector??e,o=s._loadedInjector??a;(s.loadChildren&&!s._loadedRoutes&&void 0===s.canLoad||s.loadComponent&&!s._loadedComponent)&&r.push(this.preloadConfig(a,s)),(s.children||s._loadedRoutes)&&r.push(this.processRoutes(o,s.children??s._loadedRoutes))}return ti(r).pipe(Be())}preloadConfig(e,i){return this.preloadingStrategy.preload(i,()=>{let r;r=i.loadChildren&&void 0===i.canLoad?this.loader.loadChildren(e,i):ln(null);const s=r.pipe(Ne(a=>null===a?ln(void 0):(i._loadedRoutes=a.routes,i._loadedInjector=a.injector,this.processRoutes(a.injector??e,a.routes))));return i.loadComponent&&!i._loadedComponent?ti([s,this.loader.loadComponent(i)]).pipe(Be()):s})}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Br),gt(KH),gt(Ao),gt(Kj),gt(fk))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();const hk=new Jt("");let Xj=(()=>{class t{constructor(e,i,r,s,a={}){this.urlSerializer=e,this.transitions=i,this.viewportScroller=r,this.zone=s,this.options=a,this.lastId=0,this.lastSource="imperative",this.restoredId=0,this.store={},a.scrollPositionRestoration=a.scrollPositionRestoration||"disabled",a.anchorScrolling=a.anchorScrolling||"disabled"}init(){"disabled"!==this.options.scrollPositionRestoration&&this.viewportScroller.setHistoryScrollRestoration("manual"),this.routerEventsSubscription=this.createScrollEvents(),this.scrollEventsSubscription=this.consumeScrollEvents()}createScrollEvents(){return this.transitions.events.subscribe(e=>{e instanceof Zg?(this.store[this.lastId]=this.viewportScroller.getScrollPosition(),this.lastSource=e.navigationTrigger,this.restoredId=e.restoredState?e.restoredState.navigationId:0):e instanceof F3?(this.lastId=e.id,this.scheduleScrollEvent(e,this.urlSerializer.parse(e.urlAfterRedirects).fragment)):e instanceof fd&&0===e.code&&(this.lastSource=void 0,this.restoredId=0,this.scheduleScrollEvent(e,this.urlSerializer.parse(e.url).fragment))})}consumeScrollEvents(){return this.transitions.events.subscribe(e=>{e instanceof xj&&(e.position?"top"===this.options.scrollPositionRestoration?this.viewportScroller.scrollToPosition([0,0]):"enabled"===this.options.scrollPositionRestoration&&this.viewportScroller.scrollToPosition(e.position):e.anchor&&"enabled"===this.options.anchorScrolling?this.viewportScroller.scrollToAnchor(e.anchor):"disabled"!==this.options.scrollPositionRestoration&&this.viewportScroller.scrollToPosition([0,0]))})}scheduleScrollEvent(e,i){this.zone.runOutsideAngular(()=>{setTimeout(()=>{this.zone.run(()=>{this.transitions.events.next(new xj(e,"popstate"===this.lastSource?this.store[this.restoredId]:null,i))})},0)})}ngOnDestroy(){this.routerEventsSubscription?.unsubscribe(),this.scrollEventsSubscription?.unsubscribe()}static#e=this.\u0275fac=function(i){!function JP(){throw new Error("invalid")}()};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac})}return t})();function Tl(t,n){return{\u0275kind:t,\u0275providers:n}}function Jj(){const t=Kt(ks);return n=>{const e=t.get(P2);if(n!==e.components[0])return;const i=t.get(Br),r=t.get(eW);1===t.get(pk)&&i.initialNavigation(),t.get(tW,null,Mi.Optional)?.setUpPreloading(),t.get(hk,null,Mi.Optional)?.init(),i.resetRootComponentType(e.componentTypes[0]),r.closed||(r.next(),r.complete(),r.unsubscribe())}}const eW=new Jt("",{factory:()=>new U}),pk=new Jt("",{providedIn:"root",factory:()=>1}),tW=new Jt("");function rbe(t){return Tl(0,[{provide:tW,useExisting:ebe},{provide:Kj,useExisting:t}])}const nW=new Jt("ROUTER_FORROOT_GUARD"),abe=[$x,{provide:L8,useClass:ZM},Br,F8,{provide:lo,useFactory:function Qj(t){return t.routerState.root},deps:[Br]},fk,[]];function obe(){return new iV("Router",Br)}let iW=(()=>{class t{constructor(e){}static forRoot(e,i){return{ngModule:t,providers:[abe,[],{provide:vd,multi:!0,useValue:e},{provide:nW,useFactory:dbe,deps:[[Br,new _f,new bf]]},{provide:iv,useValue:i||{}},i?.useHash?{provide:y4,useClass:Xde}:{provide:y4,useClass:RV},{provide:hk,useFactory:()=>{const t=Kt(ufe),n=Kt(Xn),e=Kt(iv),i=Kt(nv),r=Kt(L8);return e.scrollOffset&&t.setOffset(e.scrollOffset),new Xj(r,i,t,n,e)}},i?.preloadingStrategy?rbe(i.preloadingStrategy).\u0275providers:[],{provide:iV,multi:!0,useFactory:obe},i?.initialNavigation?fbe(i):[],i?.bindToComponentInputs?Tl(8,[Ij,{provide:Xg,useExisting:Ij}]).\u0275providers:[],[{provide:rW,useFactory:Jj},{provide:Nx,multi:!0,useExisting:rW}]]}}static forChild(e){return{ngModule:t,providers:[{provide:vd,multi:!0,useValue:e}]}}static#e=this.\u0275fac=function(i){return new(i||t)(gt(nW,8))};static#t=this.\u0275mod=li({type:t});static#n=this.\u0275inj=oi({})}return t})();function dbe(t){return"guarded"}function fbe(t){return["disabled"===t.initialNavigation?Tl(3,[{provide:Tx,multi:!0,useFactory:()=>{const n=Kt(Br);return()=>{n.setUpLocationChangeListener()}}},{provide:pk,useValue:2}]).\u0275providers:[],"enabledBlocking"===t.initialNavigation?Tl(2,[{provide:pk,useValue:0},{provide:Tx,multi:!0,deps:[ks],useFactory:n=>{const e=n.get(Yde,Promise.resolve());return()=>e.then(()=>new Promise(i=>{const r=n.get(Br),s=n.get(eW);Zj(r,()=>{i(!0)}),n.get(nv).afterPreactivation=()=>(i(!0),s.closed?ln(void 0):s),r.initialNavigation()}))}}]).\u0275providers:[]]}const rW=new Jt("");var Ge=$(5861),vq={prefix:"fas",iconName:"gas-pump",icon:[512,512,[9981],"f52f","M32 64C32 28.7 60.7 0 96 0H256c35.3 0 64 28.7 64 64V256h8c48.6 0 88 39.4 88 88v32c0 13.3 10.7 24 24 24s24-10.7 24-24V222c-27.6-7.1-48-32.2-48-62V96L384 64c-8.8-8.8-8.8-23.2 0-32s23.2-8.8 32 0l77.3 77.3c12 12 18.7 28.3 18.7 45.3V168v24 32V376c0 39.8-32.2 72-72 72s-72-32.2-72-72V344c0-22.1-17.9-40-40-40h-8V448c17.7 0 32 14.3 32 32s-14.3 32-32 32H32c-17.7 0-32-14.3-32-32s14.3-32 32-32V64zM96 80v96c0 8.8 7.2 16 16 16H240c8.8 0 16-7.2 16-16V80c0-8.8-7.2-16-16-16H112c-8.8 0-16 7.2-16 16z"]},bk={prefix:"fas",iconName:"globe",icon:[512,512,[127760],"f0ac","M352 256c0 22.2-1.2 43.6-3.3 64H163.3c-2.2-20.4-3.3-41.8-3.3-64s1.2-43.6 3.3-64H348.7c2.2 20.4 3.3 41.8 3.3 64zm28.8-64H503.9c5.3 20.5 8.1 41.9 8.1 64s-2.8 43.5-8.1 64H380.8c2.1-20.6 3.2-42 3.2-64s-1.1-43.4-3.2-64zm112.6-32H376.7c-10-63.9-29.8-117.4-55.3-151.6c78.3 20.7 142 77.5 171.9 151.6zm-149.1 0H167.7c6.1-36.4 15.5-68.6 27-94.7c10.5-23.6 22.2-40.7 33.5-51.5C239.4 3.2 248.7 0 256 0s16.6 3.2 27.8 13.8c11.3 10.8 23 27.9 33.5 51.5c11.6 26 20.9 58.2 27 94.7zm-209 0H18.6C48.6 85.9 112.2 29.1 190.6 8.4C165.1 42.6 145.3 96.1 135.3 160zM8.1 192H131.2c-2.1 20.6-3.2 42-3.2 64s1.1 43.4 3.2 64H8.1C2.8 299.5 0 278.1 0 256s2.8-43.5 8.1-64zM194.7 446.6c-11.6-26-20.9-58.2-27-94.6H344.3c-6.1 36.4-15.5 68.6-27 94.6c-10.5 23.6-22.2 40.7-33.5 51.5C272.6 508.8 263.3 512 256 512s-16.6-3.2-27.8-13.8c-11.3-10.8-23-27.9-33.5-51.5zM135.3 352c10 63.9 29.8 117.4 55.3 151.6C112.2 482.9 48.6 426.1 18.6 352H135.3zm358.1 0c-30 74.1-93.6 130.9-171.9 151.6c25.5-34.2 45.2-87.7 55.3-151.6H493.4z"]},$q={prefix:"fas",iconName:"repeat",icon:[512,512,[128257],"f363","M0 224c0 17.7 14.3 32 32 32s32-14.3 32-32c0-53 43-96 96-96H320v32c0 12.9 7.8 24.6 19.8 29.6s25.7 2.2 34.9-6.9l64-64c12.5-12.5 12.5-32.8 0-45.3l-64-64c-9.2-9.2-22.9-11.9-34.9-6.9S320 19.1 320 32V64H160C71.6 64 0 135.6 0 224zm512 64c0-17.7-14.3-32-32-32s-32 14.3-32 32c0 53-43 96-96 96H192V352c0-12.9-7.8-24.6-19.8-29.6s-25.7-2.2-34.9 6.9l-64 64c-12.5 12.5-12.5 32.8 0 45.3l64 64c9.2 9.2 22.9 11.9 34.9 6.9s19.8-16.6 19.8-29.6V448H352c88.4 0 160-71.6 160-160z"]},Ck={prefix:"fas",iconName:"caret-up",icon:[320,512,[],"f0d8","M182.6 137.4c-12.5-12.5-32.8-12.5-45.3 0l-128 128c-9.2 9.2-11.9 22.9-6.9 34.9s16.6 19.8 29.6 19.8H288c12.9 0 24.6-7.8 29.6-19.8s2.2-25.7-6.9-34.9l-128-128z"]},G8={prefix:"fas",iconName:"circle-check",icon:[512,512,[61533,"check-circle"],"f058","M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM369 209L241 337c-9.4 9.4-24.6 9.4-33.9 0l-64-64c-9.4-9.4-9.4-24.6 0-33.9s24.6-9.4 33.9 0l47 47L335 175c9.4-9.4 24.6-9.4 33.9 0s9.4 24.6 0 33.9z"]},zZ={prefix:"fas",iconName:"cube",icon:[512,512,[],"f1b2","M234.5 5.7c13.9-5 29.1-5 43.1 0l192 68.6C495 83.4 512 107.5 512 134.6V377.4c0 27-17 51.2-42.5 60.3l-192 68.6c-13.9 5-29.1 5-43.1 0l-192-68.6C17 428.6 0 404.5 0 377.4V134.6c0-27 17-51.2 42.5-60.3l192-68.6zM256 66L82.3 128 256 190l173.7-62L256 66zm32 368.6l160-57.1v-188L288 246.6v188z"]},HZ={prefix:"fas",iconName:"circle",icon:[512,512,[128308,128309,128992,128993,128994,128995,128996,9679,9898,9899,11044,61708,61915],"f111","M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512z"]},jZ={prefix:"fas",iconName:"wallet",icon:[512,512,[],"f555","M64 32C28.7 32 0 60.7 0 96V416c0 35.3 28.7 64 64 64H448c35.3 0 64-28.7 64-64V192c0-35.3-28.7-64-64-64H80c-8.8 0-16-7.2-16-16s7.2-16 16-16H448c17.7 0 32-14.3 32-32s-14.3-32-32-32H64zM416 272a32 32 0 1 1 0 64 32 32 0 1 1 0-64z"]},Lk={prefix:"fas",iconName:"circle-question",icon:[512,512,[62108,"question-circle"],"f059","M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM169.8 165.3c7.9-22.3 29.1-37.3 52.8-37.3h58.3c34.9 0 63.1 28.3 63.1 63.1c0 22.6-12.1 43.5-31.7 54.8L280 264.4c-.2 13-10.9 23.6-24 23.6c-13.3 0-24-10.7-24-24V250.5c0-8.6 4.6-16.5 12.1-20.8l44.3-25.4c4.7-2.7 7.6-7.7 7.6-13.1c0-8.4-6.8-15.1-15.1-15.1H222.6c-3.4 0-6.4 2.1-7.5 5.3l-.4 1.2c-4.4 12.5-18.2 19-30.6 14.6s-19-18.2-14.6-30.6l.4-1.2zM224 352a32 32 0 1 1 64 0 32 32 0 1 1 -64 0z"]},Hk={prefix:"fas",iconName:"arrow-left",icon:[448,512,[8592],"f060","M9.4 233.4c-12.5 12.5-12.5 32.8 0 45.3l160 160c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L109.2 288 416 288c17.7 0 32-14.3 32-32s-14.3-32-32-32l-306.7 0L214.6 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0l-160 160z"]},$k={prefix:"fas",iconName:"minus",icon:[448,512,[8211,8722,10134,"subtract"],"f068","M432 256c0 17.7-14.3 32-32 32L48 288c-17.7 0-32-14.3-32-32s14.3-32 32-32l352 0c17.7 0 32 14.3 32 32z"]},hv={prefix:"fas",iconName:"gear",icon:[512,512,[9881,"cog"],"f013","M495.9 166.6c3.2 8.7 .5 18.4-6.4 24.6l-43.3 39.4c1.1 8.3 1.7 16.8 1.7 25.4s-.6 17.1-1.7 25.4l43.3 39.4c6.9 6.2 9.6 15.9 6.4 24.6c-4.4 11.9-9.7 23.3-15.8 34.3l-4.7 8.1c-6.6 11-14 21.4-22.1 31.2c-5.9 7.2-15.7 9.6-24.5 6.8l-55.7-17.7c-13.4 10.3-28.2 18.9-44 25.4l-12.5 57.1c-2 9.1-9 16.3-18.2 17.8c-13.8 2.3-28 3.5-42.5 3.5s-28.7-1.2-42.5-3.5c-9.2-1.5-16.2-8.7-18.2-17.8l-12.5-57.1c-15.8-6.5-30.6-15.1-44-25.4L83.1 425.9c-8.8 2.8-18.6 .3-24.5-6.8c-8.1-9.8-15.5-20.2-22.1-31.2l-4.7-8.1c-6.1-11-11.4-22.4-15.8-34.3c-3.2-8.7-.5-18.4 6.4-24.6l43.3-39.4C64.6 273.1 64 264.6 64 256s.6-17.1 1.7-25.4L22.4 191.2c-6.9-6.2-9.6-15.9-6.4-24.6c4.4-11.9 9.7-23.3 15.8-34.3l4.7-8.1c6.6-11 14-21.4 22.1-31.2c5.9-7.2 15.7-9.6 24.5-6.8l55.7 17.7c13.4-10.3 28.2-18.9 44-25.4l12.5-57.1c2-9.1 9-16.3 18.2-17.8C227.3 1.2 241.5 0 256 0s28.7 1.2 42.5 3.5c9.2 1.5 16.2 8.7 18.2 17.8l12.5 57.1c15.8 6.5 30.6 15.1 44 25.4l55.7-17.7c8.8-2.8 18.6-.3 24.5 6.8c8.1 9.8 15.5 20.2 22.1 31.2l4.7 8.1c6.1 11 11.4 22.4 15.8 34.3zM256 336a80 80 0 1 0 0-160 80 80 0 1 0 0 160z"]},jk={prefix:"fas",iconName:"caret-down",icon:[320,512,[],"f0d7","M137.4 374.6c12.5 12.5 32.8 12.5 45.3 0l128-128c9.2-9.2 11.9-22.9 6.9-34.9s-16.6-19.8-29.6-19.8L32 192c-12.9 0-24.6 7.8-29.6 19.8s-2.2 25.7 6.9 34.9l128 128z"]},Wk={prefix:"fas",iconName:"coins",icon:[512,512,[],"f51e","M512 80c0 18-14.3 34.6-38.4 48c-29.1 16.1-72.5 27.5-122.3 30.9c-3.7-1.8-7.4-3.5-11.3-5C300.6 137.4 248.2 128 192 128c-8.3 0-16.4 .2-24.5 .6l-1.1-.6C142.3 114.6 128 98 128 80c0-44.2 86-80 192-80S512 35.8 512 80zM160.7 161.1c10.2-.7 20.7-1.1 31.3-1.1c62.2 0 117.4 12.3 152.5 31.4C369.3 204.9 384 221.7 384 240c0 4-.7 7.9-2.1 11.7c-4.6 13.2-17 25.3-35 35.5c0 0 0 0 0 0c-.1 .1-.3 .1-.4 .2l0 0 0 0c-.3 .2-.6 .3-.9 .5c-35 19.4-90.8 32-153.6 32c-59.6 0-112.9-11.3-148.2-29.1c-1.9-.9-3.7-1.9-5.5-2.9C14.3 274.6 0 258 0 240c0-34.8 53.4-64.5 128-75.4c10.5-1.5 21.4-2.7 32.7-3.5zM416 240c0-21.9-10.6-39.9-24.1-53.4c28.3-4.4 54.2-11.4 76.2-20.5c16.3-6.8 31.5-15.2 43.9-25.5V176c0 19.3-16.5 37.1-43.8 50.9c-14.6 7.4-32.4 13.7-52.4 18.5c.1-1.8 .2-3.5 .2-5.3zm-32 96c0 18-14.3 34.6-38.4 48c-1.8 1-3.6 1.9-5.5 2.9C304.9 404.7 251.6 416 192 416c-62.8 0-118.6-12.6-153.6-32C14.3 370.6 0 354 0 336V300.6c12.5 10.3 27.6 18.7 43.9 25.5C83.4 342.6 135.8 352 192 352s108.6-9.4 148.1-25.9c7.8-3.2 15.3-6.9 22.4-10.9c6.1-3.4 11.8-7.2 17.2-11.2c1.5-1.1 2.9-2.3 4.3-3.4V304v5.7V336zm32 0V304 278.1c19-4.2 36.5-9.5 52.1-16c16.3-6.8 31.5-15.2 43.9-25.5V272c0 10.5-5 21-14.9 30.9c-16.3 16.3-45 29.7-81.3 38.4c.1-1.7 .2-3.5 .2-5.3zM192 448c56.2 0 108.6-9.4 148.1-25.9c16.3-6.8 31.5-15.2 43.9-25.5V432c0 44.2-86 80-192 80S0 476.2 0 432V396.6c12.5 10.3 27.6 18.7 43.9 25.5C83.4 438.6 135.8 448 192 448z"]},gv={prefix:"fas",iconName:"bolt",icon:[448,512,[9889,"zap"],"f0e7","M349.4 44.6c5.9-13.7 1.5-29.7-10.6-38.5s-28.6-8-39.9 1.8l-256 224c-10 8.8-13.6 22.9-8.9 35.3S50.7 288 64 288H175.5L98.6 467.4c-5.9 13.7-1.5 29.7 10.6 38.5s28.6 8 39.9-1.8l256-224c10-8.8 13.6-22.9 8.9-35.3s-16.6-20.7-30-20.7H272.5L349.4 44.6z"]},Kk={prefix:"fas",iconName:"less-than",icon:[384,512,[62774],"3c","M380.6 81.7c7.9 15.8 1.5 35-14.3 42.9L103.6 256 366.3 387.4c15.8 7.9 22.2 27.1 14.3 42.9s-27.1 22.2-42.9 14.3l-320-160C6.8 279.2 0 268.1 0 256s6.8-23.2 17.7-28.6l320-160c15.8-7.9 35-1.5 42.9 14.3z"]},H4={prefix:"fas",iconName:"arrow-down",icon:[384,512,[8595],"f063","M169.4 470.6c12.5 12.5 32.8 12.5 45.3 0l160-160c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L224 370.8 224 64c0-17.7-14.3-32-32-32s-32 14.3-32 32l0 306.7L54.6 265.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3l160 160z"]},bv={prefix:"fas",iconName:"link",icon:[640,512,[128279,"chain"],"f0c1","M579.8 267.7c56.5-56.5 56.5-148 0-204.5c-50-50-128.8-56.5-186.3-15.4l-1.6 1.1c-14.4 10.3-17.7 30.3-7.4 44.6s30.3 17.7 44.6 7.4l1.6-1.1c32.1-22.9 76-19.3 103.8 8.6c31.5 31.5 31.5 82.5 0 114L422.3 334.8c-31.5 31.5-82.5 31.5-114 0c-27.9-27.9-31.5-71.8-8.6-103.8l1.1-1.6c10.3-14.4 6.9-34.4-7.4-44.6s-34.4-6.9-44.6 7.4l-1.1 1.6C206.5 251.2 213 330 263 380c56.5 56.5 148 56.5 204.5 0L579.8 267.7zM60.2 244.3c-56.5 56.5-56.5 148 0 204.5c50 50 128.8 56.5 186.3 15.4l1.6-1.1c14.4-10.3 17.7-30.3 7.4-44.6s-30.3-17.7-44.6-7.4l-1.6 1.1c-32.1 22.9-76 19.3-103.8-8.6C74 372 74 321 105.5 289.5L217.7 177.2c31.5-31.5 82.5-31.5 114 0c27.9 27.9 31.5 71.8 8.6 103.9l-1.1 1.6c-10.3 14.4-6.9 34.4 7.4 44.6s34.4 6.9 44.6-7.4l1.1-1.6C433.5 260.8 427 182 377 132c-56.5-56.5-148-56.5-204.5 0L60.2 244.3z"]},yd={prefix:"fas",iconName:"magnifying-glass",icon:[512,512,[128269,"search"],"f002","M416 208c0 45.9-14.9 88.3-40 122.7L502.6 457.4c12.5 12.5 12.5 32.8 0 45.3s-32.8 12.5-45.3 0L330.7 376c-34.4 25.2-76.8 40-122.7 40C93.1 416 0 322.9 0 208S93.1 0 208 0S416 93.1 416 208zM208 352a144 144 0 1 0 0-288 144 144 0 1 0 0 288z"]},Mc={prefix:"fas",iconName:"chevron-down",icon:[512,512,[],"f078","M233.4 406.6c12.5 12.5 32.8 12.5 45.3 0l192-192c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L256 338.7 86.6 169.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3l192 192z"]},_d={prefix:"fas",iconName:"plus",icon:[448,512,[10133,61543,"add"],"2b","M256 80c0-17.7-14.3-32-32-32s-32 14.3-32 32V224H48c-17.7 0-32 14.3-32 32s14.3 32 32 32H192V432c0 17.7 14.3 32 32 32s32-14.3 32-32V288H400c17.7 0 32-14.3 32-32s-14.3-32-32-32H256V80z"]},kc={prefix:"fas",iconName:"xmark",icon:[384,512,[128473,10005,10006,10060,215,"close","multiply","remove","times"],"f00d","M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"]},dX={prefix:"fas",iconName:"chevron-right",icon:[320,512,[9002],"f054","M310.6 233.4c12.5 12.5 12.5 32.8 0 45.3l-192 192c-12.5 12.5-32.8 12.5-45.3 0s-12.5-32.8 0-45.3L242.7 256 73.4 86.6c-12.5-12.5-12.5-32.8 0-45.3s32.8-12.5 45.3 0l192 192z"]},aS={prefix:"fas",iconName:"percent",icon:[384,512,[62101,62785,"percentage"],"25","M374.6 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0l-320 320c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0l320-320zM128 128A64 64 0 1 0 0 128a64 64 0 1 0 128 0zM384 384a64 64 0 1 0 -128 0 64 64 0 1 0 128 0z"]},wv={prefix:"fas",iconName:"spinner",icon:[512,512,[],"f110","M304 48a48 48 0 1 0 -96 0 48 48 0 1 0 96 0zm0 416a48 48 0 1 0 -96 0 48 48 0 1 0 96 0zM48 304a48 48 0 1 0 0-96 48 48 0 1 0 0 96zm464-48a48 48 0 1 0 -96 0 48 48 0 1 0 96 0zM142.9 437A48 48 0 1 0 75 369.1 48 48 0 1 0 142.9 437zm0-294.2A48 48 0 1 0 75 75a48 48 0 1 0 67.9 67.9zM369.1 437A48 48 0 1 0 437 369.1 48 48 0 1 0 369.1 437z"]},U3={prefix:"fas",iconName:"check",icon:[448,512,[10003,10004],"f00c","M438.6 105.4c12.5 12.5 12.5 32.8 0 45.3l-256 256c-12.5 12.5-32.8 12.5-45.3 0l-128-128c-12.5-12.5-12.5-32.8 0-45.3s32.8-12.5 45.3 0L160 338.7 393.4 105.4c12.5-12.5 32.8-12.5 45.3 0z"]},Ml={prefix:"fas",iconName:"triangle-exclamation",icon:[512,512,[9888,"exclamation-triangle","warning"],"f071","M256 32c14.2 0 27.3 7.5 34.5 19.8l216 368c7.3 12.4 7.3 27.7 .2 40.1S486.3 480 472 480H40c-14.3 0-27.6-7.7-34.7-20.1s-7-27.8 .2-40.1l216-368C228.7 39.5 241.8 32 256 32zm0 128c-13.3 0-24 10.7-24 24V296c0 13.3 10.7 24 24 24s24-10.7 24-24V184c0-13.3-10.7-24-24-24zm32 224a32 32 0 1 0 -64 0 32 32 0 1 0 64 0z"]},Tv={prefix:"fas",iconName:"share",icon:[512,512,["mail-forward"],"f064","M307 34.8c-11.5 5.1-19 16.6-19 29.2v64H176C78.8 128 0 206.8 0 304C0 417.3 81.5 467.9 100.2 478.1c2.5 1.4 5.3 1.9 8.1 1.9c10.9 0 19.7-8.9 19.7-19.7c0-7.5-4.3-14.4-9.8-19.5C108.8 431.9 96 414.4 96 384c0-53 43-96 96-96h96v64c0 12.6 7.4 24.1 19 29.2s25 3 34.4-5.4l160-144c6.7-6.1 10.6-14.7 10.6-23.8s-3.8-17.7-10.6-23.8l-160-144c-9.4-8.5-22.9-10.6-34.4-5.4z"]};const As="0x0000000000000000000000000000000000000000";var Oe=$(4138),yt=function(t){return t[t.Now=0]="Now",t[t.Hour=1]="Hour",t[t.Day=2]="Day",t[t.Week=3]="Week",t[t.Month=4]="Month",t[t.Year=5]="Year",t[t.All=6]="All",t}(yt||{}),Dn=function(t){return t[t.Pending=0]="Pending",t[t.Loading=1]="Loading",t[t.Success=2]="Success",t[t.Error=3]="Error",t}(Dn||{}),hr=function(t){return t[t.Both=0]="Both",t[t.Left=1]="Left",t[t.Right=2]="Right",t[t.Static=3]="Static",t}(hr||{}),Mv=function(t){return t.Volume="Volume",t.Liquidity="Liquidity",t.Price="Price",t}(Mv||{}),kv=function(t){return t.Volume="Volume",t.Price="Price",t.TotalValueLocked="TVL",t}(kv||{}),k1=function(t){return t.All="All",t.Deposits="Deposits",t.Withdraws="Withdraws",t.Swaps="Swaps",t}(k1||{}),Rr=function(t){return t.None="None",t.Awaiting="Awaiting",t.Pending="Pending",t.Success="Success",t.Error="Error",t}(Rr||{});function pS(t){return{formatters:void 0,fees:void 0,serializers:void 0,...t}}const an=pS({id:1,name:"Ethereum",nativeCurrency:{name:"Ether",symbol:"ETH",decimals:18},rpcUrls:{default:{http:["https://cloudflare-eth.com"]}},blockExplorers:{default:{name:"Etherscan",url:"https://etherscan.io",apiUrl:"https://api.etherscan.io/api"}},contracts:{ensRegistry:{address:"0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"},ensUniversalResolver:{address:"0xce01f8eee7E479C928F8919abD53E553a36CeF67",blockCreated:19258213},multicall3:{address:"0xca11bde05977b3631167028862be2a173976ca11",blockCreated:14353601}}}),bi=pS({id:42161,name:"Arbitrum One",nativeCurrency:{name:"Ether",symbol:"ETH",decimals:18},rpcUrls:{default:{http:["https://arb1.arbitrum.io/rpc"]}},blockExplorers:{default:{name:"Arbiscan",url:"https://arbiscan.io",apiUrl:"https://api.arbiscan.io/api"}},contracts:{multicall3:{address:"0xca11bde05977b3631167028862be2a173976ca11",blockCreated:7654707}}}),fi=pS({id:11155111,name:"Sepolia",nativeCurrency:{name:"Sepolia Ether",symbol:"ETH",decimals:18},rpcUrls:{default:{http:["https://rpc.sepolia.org"]}},blockExplorers:{default:{name:"Etherscan",url:"https://sepolia.etherscan.io",apiUrl:"https://api-sepolia.etherscan.io/api"}},contracts:{multicall3:{address:"0xca11bde05977b3631167028862be2a173976ca11",blockCreated:751532},ensRegistry:{address:"0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"},ensUniversalResolver:{address:"0xc8Af999e38273D658BE1b921b88A9Ddf005769cC",blockCreated:5317080}},testnet:!0}),Sv={[an.id]:"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",[bi.id]:"0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",[fi.id]:"0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9"},kr={[an.id]:{BAL:"0xba100000625a3754423978a60c9317c58a424e3D",BPT:"0x9232a548DD9E81BaC65500b5e0d918F8Ba93675C",LIT:"0xfd0205066521550D7d7AB19DA8F72bb004b4C341",WETH:"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",oLIT:"0x627fee87d0D9D2c55098A06ac805Db8F98B158Aa",xoLIT:"0x24F21b1864d4747a5c99045c96dA11DBFDa378f7",veLIT:"0xf17d23136B4FeAd139f54fB766c8795faae09660"},[bi.id]:{oLIT:"0x627fee87d0D9D2c55098A06ac805Db8F98B158Aa",xoLIT:"0x24F21b1864d4747a5c99045c96dA11DBFDa378f7"},[fi.id]:{}},TGe={[an.id]:{ETH:"0x0000000000000000000000000000000000000000",WETH:"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",WBTC:"0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",DAI:"0x6b175474e89094c44da98b954eedeac495271d0f",USDC:"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",USDT:"0xdac17f958d2ee523a2206206994597c13d831ec7"},[bi.id]:{ETH:"0x0000000000000000000000000000000000000000",WETH:"0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",ARB:"0x912CE59144191C1204E64559FE8253a0e49E6548",DAI:"0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1",USDC:"0xaf88d065e77c8cC2239327C5EDb3A432268e5831",USDT:"0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9"},[fi.id]:{ETH:"0x0000000000000000000000000000000000000000",WETH:"0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9",DAI:"0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357",USDC:"0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8",USDT:"0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0"}},EQ={[an.id]:{DAI:"0x6b175474e89094c44da98b954eedeac495271d0f",USDC:"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",USDT:"0xdac17f958d2ee523a2206206994597c13d831ec7",FRAX:"0x853d955aCEf822Db058eb8505911ED77F175b99e",LUSD:"0x5f98805A4E8be255a32880FDeC7F6728C6568bA0",GRAI:"0x15f74458aE0bFdAA1a96CA1aa779D715Cc1Eefe4",GHO:"0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f",DOLA:"0x865377367054516e17014CcdED1e7d814EDC9ce4",BUSD:"0x4Fabb145d64652a948d72533023f6E7A623C7C53",TUSD:"0x0000000000085d4780B73119b644AE5ecd22b376",FDUSD:"0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409",USDP:"0x8E870D67F660D95d5be530380D0eC0bd388289E1",mkUSD:"0x4591DBfF62656E7859Afe5e45f6f47D3669fBB28",GUSD:"0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd",PYUSD:"0x6c3ea9036406852006290770BEdFcAbA0e23A0e8"},[bi.id]:{DAI:"0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1",USDC:"0xaf88d065e77c8cC2239327C5EDb3A432268e5831",USDCe:"0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8",USDT:"0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9",FRAX:"0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F",LUSD:"0x93b346b6BC2548dA6A1E7d98E9a421B42541425b",GRAI:"0x894134a25a5faC1c2C26F1d8fBf05111a3CB9487"},[fi.id]:{USDC:"0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8",USDT:"0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0",DAI:"0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357"}},V4={[an.id]:{stETH:"0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84",wstETH:"0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0",rETH:"0xae78736Cd615f374D3085123A210448E74Fc6393",swETH:"0xf951E335afb289353dc249e82926178EaC7DEd78",cbETH:"0xBe9895146f7AF43049ca1c1AE358B0541Ea49704"},[bi.id]:{wstETH:"0x0fBcbaEA96Ce0cF7Ee00A8c19c3ab6f5Dc8E1921",rETH:"0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8",swETH:"0xbc011A12Da28e8F0f528d9eE5E7039E22F91cf18",cbETH:"0x1DEBd73E752bEaF79865Fd6446b0c970EaE7732f"},[fi.id]:{}};var Q8=$(9526);const AQ={[an.id]:"0x892b62134F51034CB256A040ca15769Ab26Af2E0",[bi.id]:null,[fi.id]:null},Fo={[an.id]:null,[bi.id]:null,[fi.id]:"0x6B5De0Da16c77b753D05a7A4c1c7880a8A0dA764"},mS={[an.id]:null,[bi.id]:null,[fi.id]:"0x4A11123A775B96a16aBCaF4d366e03459C15c38F"},J8={[an.id]:null,[bi.id]:null,[fi.id]:null},IQ={[an.id]:null,[bi.id]:"0xe4666F0937B62d64C10316DB0b7061549F87e95F",[fi.id]:null},DQ={[an.id]:null,[bi.id]:null,[fi.id]:"0xC959483DBa39aa9E78757139af0e9a2EDEb3f42D"},Ev={[an.id]:"0x951f99350d816c0E160A2C71DEfE828BdfC17f12",[bi.id]:null,[fi.id]:null},F4={[an.id]:"0x901c8aA6A61f74aC95E7f397E22A0Ac7c1242218",[bi.id]:null,[fi.id]:null},NQ={[an.id]:"0x9a8FEe232DCF73060Af348a1B62Cdb0a19852d13",[bi.id]:"0x77B1825b2FeB8AA3F8CF78809e7AEb18E0dF719d",[fi.id]:null},MGe={[an.id]:"0x00000000002Fd5Aeb385D324B580FCa7c83823A0",[bi.id]:"0x00000000002Fd5Aeb385D324B580FCa7c83823A0",[fi.id]:"0x00000000002Fd5Aeb385D324B580FCa7c83823A0"},uo={[an.id]:"0x000000000022D473030F116dDEE9F6B43aC78BA3",[bi.id]:"0x000000000022D473030F116dDEE9F6B43aC78BA3",[fi.id]:"0x000000000022D473030F116dDEE9F6B43aC78BA3"},B4={[an.id]:null,[bi.id]:null,[fi.id]:"0xD5AF63d8e0E23bbd254F04F86558F7F84d8F85eb"},$3={[an.id]:"0xDef1C0ded9bec7F1a1670819833240f027b25EfF",[bi.id]:"0xDef1C0ded9bec7F1a1670819833240f027b25EfF",[fi.id]:"0xDef1C0ded9bec7F1a1670819833240f027b25EfF"},Jr_rollbar={accessToken:"68d6f353c7f949348bfc98358d4ece8c",captureUncaught:!0,captureUnhandledRejections:!0},Jr_ALCHEMY_MAINNET_KEY="M5ORUVTDLo2uYvf2izA9UEyryO-GVH5d",Jr_SUBGRAPH_MAINNET="https://api.thegraph.com/subgraphs/name/bunniapp/bunni-v2-ethereum";let Ur=(()=>{class t{constructor(e,i,r){this.route=e,this.router=i,this.ngZone=r,this.list=[fi],this.ids={[an.id]:an,[bi.id]:bi,[fi.id]:fi},this.slugs={mainnet:an,arbitrum:bi,sepolia:fi}}get slug(){return this.route.snapshot.queryParams.chain}rpc(e,i=!1){switch(e.id){case an.id:return`${i?"wss":"https"}://eth-mainnet.g.alchemy.com/v2/${Jr_ALCHEMY_MAINNET_KEY}`;case bi.id:return(i?"wss":"https")+"://arb-mainnet.g.alchemy.com/v2/bJQpStjckrDSor32ZeGU4g3CYOgmcPHk";case fi.id:return(i?"wss":"https")+"://eth-sepolia.g.alchemy.com/v2/rpDrPK9AKpJKYDecx9XCnhqnDwfTfQfj";default:return`${i?"wss":"https"}://eth-mainnet.g.alchemy.com/v2/${Jr_ALCHEMY_MAINNET_KEY}`}}supported(e){return!!this.list.find(i=>i.id===e.id)}gaugeSupported(e){return null!==F4[e.id]||null!==IQ[e.id]}chainToSlug(e){return Object.keys(this.slugs).find(i=>this.slugs[i].id===e.id)}slugIsValid(e){return e&&Object.keys(this.slugs).includes(e)}slugToChain(e){return this.slugs[e]}updateSlug(e){this.ngZone.run(()=>{this.router.navigate([],{queryParams:{chain:this.chainToSlug(e)},replaceUrl:!0,queryParamsHandling:"merge"})})}llamaId(e){switch(e.id){case an.id:return"ethereum";case bi.id:return"arbitrum";case fi.id:return"sep";default:return null}}static#e=this.\u0275fac=function(i){return new(i||t)(gt(lo),gt(Br),gt(Xn))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();const gS=t=>t===yt.Hour?8760:t===yt.Day?365:t===yt.Week?52:t===yt.Month?30:t===yt.Year?1:null,ss=(t,n)=>{n=Math.max(0,Math.min(1,n));const e=t.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);if(!e)throw new Error("Invalid RGB color string format");const[,i,r,s]=e;return`rgba(${parseInt(i,10)}, ${parseInt(r,10)}, ${parseInt(s,10)}, ${n})`},Is=()=>({[yt.Now]:new Oe.Z(0),[yt.Hour]:new Oe.Z(0),[yt.Day]:new Oe.Z(0),[yt.Week]:new Oe.Z(0),[yt.Month]:new Oe.Z(0),[yt.Year]:new Oe.Z(0),[yt.All]:new Oe.Z(0)});class vS{constructor(n,e,i,r,s){this.address=n.toLowerCase(),this.blockExplorer=`${s.blockExplorers.default.url}/token/${n}`,this.chain=s,this.decimals=e,this.icon="assets/img/tokens/unknown.svg",this.name=i,this.precision=Math.pow(10,e),this.symbol=r,this.prices=Is(),this.userAllowances=Object.create({}),this.userBalance=new Oe.Z(0),this.userPermits=Object.create({})}price(n=yt.Now){return this.prices[n]}priceDelta(n=yt.Day){const e=this.price(),i=this.price(n);return i.gt(0)?e.minus(i).div(i).times(100):new Oe.Z(0)}userBalanceUSD(){return this.userBalance.times(this.price())}resetUser(){this.userAllowances=Object.create({}),this.userBalance=new Oe.Z(0),this.userPermits=Object.create({})}}class kGe extends vS{constructor(n,e,i,r,s){super(n,e,i,r,s),this.id=null,this.creationTimestamp=new Oe.Z(0),this.liquidityDensityFunction=null,this.ldfParams=null,this.hookParams=null,this.twapSecondsAgo=null,this.totalSupply=Is(),this.rawBalance0=Is(),this.rawBalance1=Is(),this.reserve0=Is(),this.reserve1=Is(),this.gauge=null,this.pool=null,this.vault0=null,this.vault1=null,this.userPosition=null}balanceCurrency0(n=yt.Now){let e=this.rawBalance0[n];if(this.vault0){const i=this.reserve0[n].times(this.vault0.pricePerVaultShare[n]);e=e.plus(i)}return e}balanceCurrency1(n=yt.Now){let e=this.rawBalance1[n];if(this.vault1){const i=this.reserve1[n].times(this.vault1.pricePerVaultShare[n]);e=e.plus(i)}return e}price(n=yt.Now){let e=new Oe.Z(0),i=new Oe.Z(0);if(this.pool&&this.pool.token0&&this.pool.token1){const r=this.rawBalance0[n].times(this.pool.token0.price(n)),s=this.rawBalance1[n].times(this.pool.token1.price(n));if(e=r.plus(s),this.vault0){const a=this.reserve0[n].times(this.vault0.pricePerVaultShare[n]).times(this.pool.token0.price(n));i=i.plus(a)}if(this.vault1){const a=this.reserve1[n].times(this.vault1.pricePerVaultShare[n]).times(this.pool.token1.price(n));i=i.plus(a)}}return this.totalSupply[n].gt(0)?e.plus(i).div(this.totalSupply[n]):new Oe.Z(0)}resetUser(){super.resetUser(),this.userPosition=null}}class SGe{constructor(n){this.bunniToken=n,this.balance=new Oe.Z(0),this.gaugeBalance=new Oe.Z(0),this.claimedRewards=new Oe.Z(0),this.currency0CostBasisPerShare=new Oe.Z(0),this.currency1CostBasisPerShare=new Oe.Z(0),this.claimedRewardsPerShare=new Oe.Z(0)}totalBalance(){return this.balance.plus(this.gaugeBalance)}currentValue(){return this.balance.plus(this.gaugeBalance).times(this.bunniToken.price())}costBasis(){const n=this.totalBalance().times(this.currency0CostBasisPerShare).times(this.bunniToken.pool.token0.price()),e=this.totalBalance().times(this.currency1CostBasisPerShare).times(this.bunniToken.pool.token1.price());return n.plus(e)}roi(){const n=this.currentValue(),e=this.costBasis();return n.minus(e).div(e)}}class EGe{constructor(n,e){this.supply=new Oe.Z(0),this.totalSupply=new Oe.Z(0),this.totalSupplyLastEpoch=new Oe.Z(0),this.apr=new Oe.Z(0),this.aprBAL=new Oe.Z(0),this.aprWETH=new Oe.Z(0),this.distributedBAL=new Oe.Z(0),this.distributedWETH=new Oe.Z(0),this.BPT=n,this.veLIT=e,this.resetUser()}resetUser(){this.userBalance=new Oe.Z(0),this.userBroadcasts=[],this.userClaimableBAL=new Oe.Z(0),this.userClaimableWETH=new Oe.Z(0),this.userLockEnd=0,this.userVoteWeightUsed=new Oe.Z(0)}}class AGe{}class IGe extends vS{constructor(n,e){super(n.toLowerCase(),18,"Timeless BUNNI-LP Gauge Deposit","BUNNI-LP-gauge",e),this.exists=!1,this.isKilled=!1,this.rootGaugeDeployed=!1,this.childGaugeDeployed=!1,this.relativeWeightCap=null,this.tokenlessProduction=null,this.totalSupply=null,this.workingSupply=null,this.currentPeriodWeight=new Oe.Z(0),this.currentPeriodVotes=new Oe.Z(0),this.nextPeriodWeight=new Oe.Z(0),this.nextPeriodVotes=new Oe.Z(0),this.resetUser(),this.bribes=[],this.quests=[],this.bunniToken=null}resetUser(){super.resetUser(),this.userClaimableReward=new Oe.Z(0),this.userVote=null,this.userWorkingBalance=new Oe.Z(0)}totalRewardValue(){let n=new Oe.Z(0);return this.bribes.forEach(e=>{n=n.plus(e.amount.times(e.token.price()))}),this.quests.forEach(e=>{n=n.plus(e.amount.times(e.token.price()))}),n}}class DGe{constructor(n){this.amount=new Oe.Z(0),this.maxTokensPerVote=new Oe.Z(0),this.token=n}}class NGe{constructor(n){this.amount=new Oe.Z(0),this.minRewardPerVote=new Oe.Z(0),this.maxRewardPerVote=new Oe.Z(0),this.minObjectiveVotes=new Oe.Z(0),this.maxObjectiveVotes=new Oe.Z(0),this.token=n}}class RGe{constructor(n){this.voter=n,this.power=new Oe.Z(0),this.weight=new Oe.Z(0),this.decay=new Oe.Z(0),this.timestamp=0,this.votePowerNextEpoch=new Oe.Z(0)}}class LGe{constructor(){}unwatch(){}}class PGe{constructor(){this.unwatchTransferFrom=null,this.unwatchTransferTo=null,this.unwatchApproval=null,this.unwatchPermit=null}unwatch(){this.unwatchTransferFrom&&this.unwatchTransferFrom(),this.unwatchTransferTo&&this.unwatchTransferTo(),this.unwatchApproval&&this.unwatchApproval(),this.unwatchPermit&&this.unwatchPermit(),this.unwatchTransferFrom=null,this.unwatchTransferTo=null,this.unwatchApproval=null,this.unwatchPermit=null}}const Av=(t,n)=>{let e=t/n;return t<0&&t%n!=0n&&e--,e*n},Iv=(t,n,e)=>t**n*e/e**n,RQ=t=>t.div(365).plus(1).pow(365).minus(1);class zGe{constructor(n,e,i,r,s,a){this.id=n.toLowerCase(),this.chain=a,this.bunniToken=null,this.hook=null,this.token0=e,this.token1=i,this.fee=r,this.tickSpacing=s,this.liquidity=new Oe.Z(0),this.sqrtPriceX96=new Oe.Z(0),this.tick=0n,this.twapTick=0n,this.currency0Price=Is(),this.currency1Price=Is(),this.volumeCurrency0=Is(),this.swapFeesCurrency0=Is(),this.managerFeesCurrency0=Is(),this.rentCurrency0=Is(),this.volumeCurrency1=Is(),this.swapFeesCurrency1=Is(),this.managerFeesCurrency1=Is(),this.rentCurrency1=Is(),this.transactions=[],this.minuteSnapshots=null,this.hourSnapshots=null,this.daySnapshots=null,this.weekSnapshots=null,this.hookParams=null,this.feeMode=null}key(){return{currency0:this.token0.address,currency1:this.token1.address,fee:this.fee.toNumber(),tickSpacing:Number(this.tickSpacing),hooks:this.hook.addresses[this.chain.id]}}totalValueLocked(n=yt.Now){let e=new Oe.Z(0),i=new Oe.Z(0);if(this.bunniToken&&this.token0&&this.token1){const r=this.bunniToken.rawBalance0[n].times(this.token0.price(n)),s=this.bunniToken.rawBalance1[n].times(this.token1.price(n));if(e=r.plus(s),this.bunniToken.vault0){const a=this.bunniToken.reserve0[n].times(this.bunniToken.vault0.pricePerVaultShare[n]).times(this.token0.price(n));i=i.plus(a)}if(this.bunniToken.vault1){const a=this.bunniToken.reserve1[n].times(this.bunniToken.vault1.pricePerVaultShare[n]).times(this.token1.price(n));i=i.plus(a)}}return e.plus(i)}volume(n){return this.volumeCurrency0[yt.Now].minus(this.volumeCurrency0[n]).times(this.token0.price())}swapFees(n){const e=this.swapFeesCurrency0[yt.Now].minus(this.swapFeesCurrency0[n]).times(this.token0.price()),i=this.swapFeesCurrency1[yt.Now].minus(this.swapFeesCurrency1[n]).times(this.token1.price());return e.plus(i)}managerFees(n){const e=this.managerFeesCurrency0[yt.Now].minus(this.managerFeesCurrency0[n]).times(this.token0.price()),i=this.managerFeesCurrency1[yt.Now].minus(this.managerFeesCurrency1[n]).times(this.token1.price());return e.plus(i)}rent(n){const e=this.rentCurrency0[yt.Now].minus(this.rentCurrency0[n]).times(this.token0.price()),i=this.rentCurrency1[yt.Now].minus(this.rentCurrency1[n]).times(this.token1.price());return e.plus(i)}rentAPR(n=yt.Day){const e=gS(n),i=this.totalValueLocked(yt.Now);return i.gt(0)?this.rent(n).times(e).div(i):new Oe.Z(0)}swapAPR(n=yt.Day){const e=gS(n),i=this.totalValueLocked(yt.Now);return i.gt(0)?this.swapFees(n).minus(this.managerFees(n)).times(e).div(i):new Oe.Z(0)}vaultAPR(n){let e=new Oe.Z(0);const i=this.totalValueLocked(yt.Now);if(i.gt(0)){if(this.bunniToken.vault0){const r=this.bunniToken.vault0.APR(n),s=this.bunniToken.reserve0[yt.Now].times(this.bunniToken.vault0.pricePerVaultShare[yt.Now]).times(this.token0.price(yt.Now));e=e.plus(r.times(s).div(i))}if(this.bunniToken.vault1){const r=this.bunniToken.vault1.APR(n),s=this.bunniToken.reserve1[yt.Now].times(this.bunniToken.vault1.pricePerVaultShare[yt.Now]).times(this.token1.price(yt.Now));e=e.plus(r.times(s).div(i))}}return e}APY(n){if(null==n||n===yt.Now||n===yt.All)return console.error("Pool: Invalid period for APY calculation"),new Oe.Z(0);const e=this.rentAPR(n),i=this.swapAPR(n),r=this.vaultAPR(n),s=e.plus(i).plus(r);return RQ(s)}}class Dv{constructor(n){this.index=n,this.periodStart=null,this.periodEnd=null,this.volumeUSD=new Oe.Z(0),this.swapFeesUSD=new Oe.Z(0),this.open=new Oe.Z(0),this.high=new Oe.Z(0),this.low=new Oe.Z(0),this.close=new Oe.Z(0)}}class OGe extends vS{constructor(n,e,i,r,s){super(n,e,i,r,s),this.faucet=!1,this.rawBalance=Is(),this.volumes=Is(),this.isStablecoin=!1,this.isLiquidStakingToken=!1,this.stakingAPR=new Oe.Z(0),this.pools=[],this.vaults=[],this.transactions=[],this.minuteSnapshots=null,this.hourSnapshots=null,this.daySnapshots=null,this.weekSnapshots=null}totalValueLocked(n=yt.Now){let e=this.rawBalance[n];return this.vaults.forEach(i=>{e=e.plus(i.reserve[n].times(i.pricePerVaultShare[n]))}),e.times(this.price(n))}volume(n){return this.volumes[yt.Now].minus(this.volumes[n]).times(this.price())}}class Nv{constructor(n,e){this.token=n,this.index=e,this.periodStart=null,this.periodEnd=null,this.totalValueLockedUSD=new Oe.Z(0),this.volumeUSD=new Oe.Z(0),this.open=new Oe.Z(0),this.high=new Oe.Z(0),this.low=new Oe.Z(0),this.close=new Oe.Z(0)}}class yS{constructor(n,e,i){this.hash=n,this.timestamp=e,this.sender=null,this.blockExplorer=`${i.blockExplorers.default.url}/tx/${n}`,this.pool=null,this.token0=null,this.token1=null,this.amount=new Oe.Z(0),this.amount0=new Oe.Z(0),this.amount1=new Oe.Z(0)}}class eh extends yS{constructor(n,e,i){super(n,e,i)}}class th extends yS{constructor(n,e,i){super(n,e,i)}}class nh extends yS{constructor(n,e,i){super(n,e,i)}}class LQ{constructor(n,e,i,r,s,a){this.address=n,this.chain=a,this.decimals=i,this.icon="assets/img/tokens/unknown.svg",this.name=r,this.precision=Math.pow(10,i),this.symbol=s,this.asset=e,this.protocol=null,this.verified=!1,this.pricePerVaultShare=Is(),this.reserve=Is()}get blockExplorer(){return`${this.chain.blockExplorers.default.url}/address/${this.address}`}APR(n){return this.pricePerVaultShare[n].eq(0)?new Oe.Z(0):this.pricePerVaultShare[yt.Now].minus(this.pricePerVaultShare[n]).div(this.pricePerVaultShare[n]).times(gS(n))}APY(n){return RQ(this.APR(n))}}let $r=(()=>{class t{constructor(){this.status=Object.create({}),this.userStatus=Object.create({}),this.bunniTokens=Object.create({}),this.escrow=Object.create({}),this.gauges=Object.create({}),this.pools=Object.create({}),this.tokens=Object.create({}),this.vaults=Object.create({}),this.globalListeners=Object.create({}),this.userListeners=Object.create({}),this.bunniTokensObservable=new Vn(this.bunniTokens),this.escrowObservable=new Vn(this.escrow),this.gaugesObservable=new Vn(this.gauges),this.poolsObservable=new Vn(this.pools),this.tokensObservable=new Vn(this.tokens),this.vaultsObservable=new Vn(this.vaults)}setStatus(e,i){this.status[e.id]=i}setUserStatus(e,i){this.userStatus[e.id]=i}setGlobalListener(e){return this.globalListeners[e.id]=new LGe,this.globalListeners[e.id]}setUserListener(e){return this.userListeners[e.id]=new PGe,this.userListeners[e.id]}setBunniToken(e,i,r,s,a){this.bunniTokens[a.id]||(this.bunniTokens[a.id]=Object.create({}));let o=this.bunniTokens[a.id][e.toLowerCase()];return o||(o=new kGe(e,i,r,s,a),this.bunniTokens[a.id][e.toLowerCase()]=o),o}setEscrow(e){this.escrow[e.id]||(this.escrow[e.id]=Object.create({}));let i=this.escrow[e.id][kr[e.id].veLIT.toLowerCase()];return i||(i=new EGe(this.tokens[e.id][kr[e.id].BPT.toLowerCase()],this.tokens[e.id][kr[e.id].veLIT.toLowerCase()]),this.escrow[e.id][kr[e.id].veLIT.toLowerCase()]=i),i}setGauge(e,i){this.gauges[i.id]||(this.gauges[i.id]=Object.create({}));let r=this.gauges[i.id][e.toLowerCase()];return r||(r=new IGe(e,i),this.gauges[i.id][e.toLowerCase()]=r),r}setPool(e,i,r,s,a,o){this.pools[o.id]||(this.pools[o.id]=Object.create({}));let c=this.pools[o.id][e.toLowerCase()];return c||(c=new zGe(e,i,r,s,a,o),this.pools[o.id][e.toLowerCase()]=c),c}setToken(e,i,r,s,a){this.tokens[a.id]||(this.tokens[a.id]=Object.create({}));let o=this.tokens[a.id][e.toLowerCase()];return o||(o=new OGe(e,i,r,s,a),this.tokens[a.id][e.toLowerCase()]=o),o}setVault(e,i,r,s,a,o){this.vaults[o.id]||(this.vaults[o.id]=Object.create({}));let c=this.vaults[o.id][e.toLowerCase()];return c||(c=new LQ(e,i,r,s,a,o),this.vaults[o.id][e.toLowerCase()]=c),c}getStatus(e){return this.status[e.id]?this.status[e.id]:Dn.Pending}getUserStatus(e){return this.userStatus[e.id]?this.userStatus[e.id]:Dn.Pending}getGlobalListener(e){return this.globalListeners[e.id]}getUserListener(e){return this.userListeners[e.id]}getBunniToken(e,i){return this.bunniTokens[i.id]||(this.bunniTokens[i.id]=Object.create({})),this.bunniTokens[i.id][e.toLowerCase()]}getBunniTokens(e){return e&&!this.bunniTokens[e.id]&&(this.bunniTokens[e.id]=Object.create({})),e?Object.values(this.bunniTokens[e.id]):Object.keys(this.bunniTokens).map(i=>Object.values(this.bunniTokens[i])).flat(1)}getERC20(e,i){const r=s=>{const a=s[i.id];return a?a[e.toLowerCase()]:void 0};return r(this.tokens)||r(this.bunniTokens)||r(this.gauges)||void 0}getEscrow(e){return this.escrow[e.id]||(this.escrow[e.id]=Object.create({})),this.escrow[e.id][kr[e.id].veLIT?.toLowerCase()]}getGauge(e,i){return this.gauges[i.id]||(this.gauges[i.id]=Object.create({})),this.gauges[i.id][e.toLowerCase()]}getGauges(e){return e&&!this.gauges[e.id]&&(this.gauges[e.id]=Object.create({})),e?Object.values(this.gauges[e.id]):Object.keys(this.gauges).map(i=>Object.values(this.gauges[i])).flat(1)}getPool(e,i){return this.pools[i.id]||(this.pools[i.id]=Object.create({})),this.pools[i.id][e]}getPools(e){return e&&!this.pools[e.id]&&(this.pools[e.id]=Object.create({})),e?Object.values(this.pools[e.id]):Object.keys(this.pools).map(i=>Object.values(this.pools[i])).flat(1)}getToken(e,i){return this.tokens[i.id]||(this.tokens[i.id]=Object.create({})),this.tokens[i.id][e.toLowerCase()]}getTokens(e){return e&&!this.tokens[e.id]&&(this.tokens[e.id]=Object.create({})),e?Object.values(this.tokens[e.id]):Object.keys(this.tokens).map(i=>Object.values(this.tokens[i])).flat(1)}getVault(e,i){return this.vaults[i.id]||(this.vaults[i.id]=Object.create({})),this.vaults[i.id][e.toLowerCase()]}getVaults(e){return e&&!this.vaults[e.id]&&(this.vaults[e.id]=Object.create({})),e?Object.values(this.vaults[e.id]):Object.keys(this.vaults).map(i=>Object.values(this.vaults[i])).flat(1)}observeBunniTokens(){this.bunniTokensObservable.next(this.bunniTokens)}observeEscrow(){this.escrowObservable.next(this.escrow)}observeGauges(){this.gaugesObservable.next(this.gauges)}observePools(){this.poolsObservable.next(this.pools)}observeTokens(){this.tokensObservable.next(this.tokens)}observeVaults(){this.vaultsObservable.next(this.vaults)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();var kl=$(277);const _S=256;let Lv,Rv=_S;function HGe(t=11){if(!Lv||Rv+t>2*_S){Lv="",Rv=0;for(let n=0;n<_S;n++)Lv+=(256+256*Math.random()|0).toString(16).substring(1)}return Lv.substring(Rv,Rv+++t)}function bS(t){const{batch:n,cacheTime:e=t.pollingInterval??4e3,ccipRead:i,key:r="base",name:s="Base Client",pollingInterval:a=4e3,type:o="base"}=t,c=t.chain,l=t.account?(0,kl.T)(t.account):void 0,{config:u,request:d,value:h}=t.transport({chain:c,pollingInterval:a}),I={account:l,batch:n,cacheTime:e,ccipRead:i,chain:c,key:r,name:s,pollingInterval:a,request:d,transport:{...u,...h},type:o,uid:HGe()};return Object.assign(I,{extend:function D(V){return we=>{const Ce=we(V);for(const Fe in I)delete Ce[Fe];const Ve={...V,...Ce};return Object.assign(Ve,{extend:D(Ve)})}}(I)})}var Sl=$(7627),ih=$(4963),El=$(4966),rh=$(1849),PQ=$(783),Qn=$(4439),VGe=$(6848),Bs=$(2618),Sc=$(8169);function wS(t,n){if(!(t instanceof Bs.G))return!1;const e=t.walk(i=>i instanceof Sc.Lu);return e instanceof Sc.Lu&&!!("ResolverNotFound"===e.data?.errorName||"ResolverWildcardNotSupported"===e.data?.errorName||"ResolverNotContract"===e.data?.errorName||"ResolverError"===e.data?.errorName||"HttpError"===e.data?.errorName||e.reason?.includes("Wildcard on non-extended resolvers is not supported")||"reverse"===n&&e.reason===VGe.$[50])}var Ec=$(770),Sn=$(9427),r2=$(3226),bd=$(7812);function zQ(t){if(66!==t.length||0!==t.indexOf("[")||65!==t.indexOf("]"))return null;const n=`0x${t.slice(1,65)}`;return(0,bd.v)(n)?n:null}function Pv(t){let n=new Uint8Array(32).fill(0);if(!t)return(0,Qn.ci)(n);const e=t.split(".");for(let i=e.length-1;i>=0;i-=1){const r=zQ(e[i]),s=r?(0,Sn.O0)(r):(0,r2.w)((0,Sn.qX)(e[i]),"bytes");n=(0,r2.w)((0,Ec.zo)([n,s]),"bytes")}return(0,Qn.ci)(n)}function FGe(t){return`[${t.slice(2)}]`}function BGe(t){const n=new Uint8Array(32).fill(0);return t?zQ(t)||(0,r2.w)((0,Sn.qX)(t)):(0,Qn.ci)(n)}function zv(t){const n=t.replace(/^\.|\.$/gm,"");if(0===n.length)return new Uint8Array(1);const e=new Uint8Array((0,Sn.qX)(n).byteLength+2);let i=0;const r=n.split(".");for(let s=0;s<r.length;s++){let a=(0,Sn.qX)(r[s]);a.byteLength>255&&(a=(0,Sn.qX)(FGe(BGe(r[s])))),e[i]=a.length,e.set(a,i+1),i+=a.length+1}return e.byteLength!==i+1?e.slice(0,i+1):e}function ri(t,n,e){return i=>t[n.name]?.(i)??t[e]?.(i)??n(t,i)}var bs=$(6577),s2=$(3979);class Bo extends Bs.G{constructor(n,{code:e,docsPath:i,metaMessages:r,shortMessage:s}){super(s,{cause:n,docsPath:i,metaMessages:r||n?.metaMessages}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"RpcError"}),Object.defineProperty(this,"code",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),this.name=n.name,this.code=n instanceof s2.bs?n.code:e??-1}}class wd extends Bo{constructor(n,e){super(n,e),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ProviderRpcError"}),Object.defineProperty(this,"data",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),this.data=e.data}}class sh extends Bo{constructor(n){super(n,{code:sh.code,shortMessage:"Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ParseRpcError"})}}Object.defineProperty(sh,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32700});class ah extends Bo{constructor(n){super(n,{code:ah.code,shortMessage:"JSON is not a valid request object."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"InvalidRequestRpcError"})}}Object.defineProperty(ah,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32600});class oh extends Bo{constructor(n){super(n,{code:oh.code,shortMessage:"The method does not exist / is not available."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"MethodNotFoundRpcError"})}}Object.defineProperty(oh,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32601});class ch extends Bo{constructor(n){super(n,{code:ch.code,shortMessage:["Invalid parameters were provided to the RPC method.","Double check you have provided the correct parameters."].join("\n")}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"InvalidParamsRpcError"})}}Object.defineProperty(ch,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32602});class U4 extends Bo{constructor(n){super(n,{code:U4.code,shortMessage:"An internal error was received."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"InternalRpcError"})}}Object.defineProperty(U4,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32603});class $4 extends Bo{constructor(n){super(n,{code:$4.code,shortMessage:["Missing or invalid parameters.","Double check you have provided the correct parameters."].join("\n")}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"InvalidInputRpcError"})}}Object.defineProperty($4,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32e3});class lh extends Bo{constructor(n){super(n,{code:lh.code,shortMessage:"Requested resource not found."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ResourceNotFoundRpcError"})}}Object.defineProperty(lh,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32001});class j3 extends Bo{constructor(n){super(n,{code:j3.code,shortMessage:"Requested resource not available."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ResourceUnavailableRpcError"})}}Object.defineProperty(j3,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32002});class uh extends Bo{constructor(n){super(n,{code:uh.code,shortMessage:"Transaction creation failed."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"TransactionRejectedRpcError"})}}Object.defineProperty(uh,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32003});class dh extends Bo{constructor(n){super(n,{code:dh.code,shortMessage:"Method is not implemented."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"MethodNotSupportedRpcError"})}}Object.defineProperty(dh,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32004});class Cd extends Bo{constructor(n){super(n,{code:Cd.code,shortMessage:"Request exceeds defined limit."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"LimitExceededRpcError"})}}Object.defineProperty(Cd,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32005});class fh extends Bo{constructor(n){super(n,{code:fh.code,shortMessage:"Version of JSON-RPC protocol is not supported."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"JsonRpcVersionUnsupportedError"})}}Object.defineProperty(fh,"code",{enumerable:!0,configurable:!0,writable:!0,value:-32006});class jr extends wd{constructor(n){super(n,{code:jr.code,shortMessage:"User rejected the request."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"UserRejectedRequestError"})}}Object.defineProperty(jr,"code",{enumerable:!0,configurable:!0,writable:!0,value:4001});class hh extends wd{constructor(n){super(n,{code:hh.code,shortMessage:"The requested method and/or account has not been authorized by the user."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"UnauthorizedProviderError"})}}Object.defineProperty(hh,"code",{enumerable:!0,configurable:!0,writable:!0,value:4100});class ph extends wd{constructor(n){super(n,{code:ph.code,shortMessage:"The Provider does not support the requested method."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"UnsupportedProviderMethodError"})}}Object.defineProperty(ph,"code",{enumerable:!0,configurable:!0,writable:!0,value:4200});class mh extends wd{constructor(n){super(n,{code:mh.code,shortMessage:"The Provider is disconnected from all chains."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ProviderDisconnectedError"})}}Object.defineProperty(mh,"code",{enumerable:!0,configurable:!0,writable:!0,value:4900});class gh extends wd{constructor(n){super(n,{code:gh.code,shortMessage:"The Provider is not connected to the requested chain."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ChainDisconnectedError"})}}Object.defineProperty(gh,"code",{enumerable:!0,configurable:!0,writable:!0,value:4901});class S1 extends wd{constructor(n){super(n,{code:S1.code,shortMessage:"An error occurred when attempting to switch chain."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"SwitchChainError"})}}Object.defineProperty(S1,"code",{enumerable:!0,configurable:!0,writable:!0,value:4902});class $Ge extends Bo{constructor(n){super(n,{shortMessage:"An unknown RPC error occurred."}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"UnknownRpcError"})}}const jGe=3;function vh(t,{abi:n,address:e,args:i,docsPath:r,functionName:s,sender:a}){const{code:o,data:c,message:l,shortMessage:u}=t instanceof Sc.VQ?t:t instanceof Bs.G?t.walk(h=>"data"in h)||t.walk():{},d=t instanceof bs.wb?new Sc.Dk({functionName:s}):[jGe,U4.code].includes(o)&&(c||l||u)?new Sc.Lu({abi:n,data:"object"==typeof c?c.data:c,functionName:s,message:u??l}):t;return new Sc.uq(d,{abi:n,args:i,contractAddress:e,docsPath:r,functionName:s,sender:a})}var yh=$(9934);function Al(t,n){return CS.apply(this,arguments)}function CS(){return(CS=(0,Ge.Z)(function*(t,n){const{abi:e,address:i,args:r,functionName:s,...a}=n,o=(0,El.R)({abi:e,args:r,functionName:s});try{const{data:c}=yield ri(t,yh.RE,"call")({...a,data:o,to:i});return(0,ih.k)({abi:e,args:r,functionName:s,data:c||"0x"})}catch(c){throw vh(c,{abi:e,address:i,args:r,docsPath:"/docs/contract/readContract",functionName:s})}})).apply(this,arguments)}function xS(){return(xS=(0,Ge.Z)(function*(t,{blockNumber:n,blockTag:e,coinType:i,name:r,gatewayUrls:s,strict:a,universalResolverAddress:o}){let c=o;if(!c){if(!t.chain)throw new Error("client chain not configured. universalResolverAddress is required.");c=(0,rh.L)({blockNumber:n,chain:t.chain,contract:"ensUniversalResolver"})}try{const l=(0,El.R)({abi:Sl.X$,functionName:"addr",...null!=i?{args:[Pv(r),BigInt(i)]}:{args:[Pv(r)]}}),u={address:c,abi:Sl.k3,functionName:"resolve",args:[(0,Qn.NC)(zv(r)),l],blockNumber:n,blockTag:e},d=ri(t,Al,"readContract"),h=s?yield d({...u,args:[...u.args,s]}):yield d(u);if("0x"===h[0])return null;const y=(0,ih.k)({abi:Sl.X$,args:null!=i?[Pv(r),BigInt(i)]:void 0,functionName:"addr",data:h[0]});return"0x"===y||"0x00"===(0,PQ.f)(y)?null:y}catch(l){if(a)throw l;if(wS(l,"resolve"))return null;throw l}})).apply(this,arguments)}class qGe extends Bs.G{constructor({data:n}){super("Unable to extract image from metadata. The metadata may be malformed or invalid.",{metaMessages:["- Metadata must be a JSON object with at least an `image`, `image_url` or `image_data` property.","",`Provided data: ${JSON.stringify(n)}`]}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"EnsAvatarInvalidMetadataError"})}}class _h extends Bs.G{constructor({reason:n}){super(`ENS NFT avatar URI is invalid. ${n}`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"EnsAvatarInvalidNftUriError"})}}class TS extends Bs.G{constructor({uri:n}){super(`Unable to resolve ENS avatar URI "${n}". The URI may be malformed, invalid, or does not respond with a valid image.`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"EnsAvatarUriResolutionError"})}}class GGe extends Bs.G{constructor({namespace:n}){super(`ENS NFT avatar namespace "${n}" is not supported. Must be "erc721" or "erc1155".`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"EnsAvatarUnsupportedNamespaceError"})}}const ZGe=/(?<protocol>https?:\/\/[^\/]*|ipfs:\/|ipns:\/|ar:\/)?(?<root>\/)?(?<subpath>ipfs\/|ipns\/)?(?<target>[\w\-.]+)(?<subtarget>\/.*)?/,YGe=/^(Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,})(\/(?<target>[\w\-.]+))?(?<subtarget>\/.*)?$/,KGe=/^data:([a-zA-Z\-/+]*);base64,([^"].*)/,XGe=/^data:([a-zA-Z\-/+]*)?(;[a-zA-Z0-9].*?)?(,)/;function MS(){return(MS=(0,Ge.Z)(function*(t){try{const n=yield fetch(t,{method:"HEAD"});return 200===n.status&&n.headers.get("content-type")?.startsWith("image/")}catch(n){return!("object"==typeof n&&typeof n.response<"u"||!globalThis.hasOwnProperty("Image"))&&new Promise(e=>{const i=new Image;i.onload=()=>{e(!0)},i.onerror=()=>{e(!1)},i.src=t})}})).apply(this,arguments)}function OQ(t,n){return t?t.endsWith("/")?t.slice(0,-1):t:n}function HQ({uri:t,gatewayUrls:n}){const e=KGe.test(t);if(e)return{uri:t,isOnChain:!0,isEncoded:e};const i=OQ(n?.ipfs,"https://ipfs.io"),r=OQ(n?.arweave,"https://arweave.net"),s=t.match(ZGe),{protocol:a,subpath:o,target:c,subtarget:l=""}=s?.groups||{},u="ipns:/"===a||"ipns/"===o,d="ipfs:/"===a||"ipfs/"===o||YGe.test(t);if(t.startsWith("http")&&!u&&!d){let y=t;return n?.arweave&&(y=t.replace(/https:\/\/arweave.net/g,n?.arweave)),{uri:y,isOnChain:!1,isEncoded:!1}}if((u||d)&&c)return{uri:`${i}/${u?"ipns":"ipfs"}/${c}${l}`,isOnChain:!1,isEncoded:!1};if("ar:/"===a&&c)return{uri:`${r}/${c}${l||""}`,isOnChain:!1,isEncoded:!1};let h=t.replace(XGe,"");if(h.startsWith("<svg")&&(h=`data:image/svg+xml;base64,${btoa(h)}`),h.startsWith("data:")||h.startsWith("{"))return{uri:h,isOnChain:!0,isEncoded:!1};throw new TS({uri:t})}function VQ(t){if("object"!=typeof t||!("image"in t)&&!("image_url"in t)&&!("image_data"in t))throw new qGe({data:t});return t.image||t.image_url||t.image_data}function kS(){return(kS=(0,Ge.Z)(function*({gatewayUrls:t,uri:n}){try{const e=yield fetch(n).then(r=>r.json());return yield SS({gatewayUrls:t,uri:VQ(e)})}catch{throw new TS({uri:n})}})).apply(this,arguments)}function SS(t){return ES.apply(this,arguments)}function ES(){return ES=(0,Ge.Z)(function*({gatewayUrls:t,uri:n}){const{uri:e,isOnChain:i}=HQ({uri:n,gatewayUrls:t});if(i||(yield function QGe(t){return MS.apply(this,arguments)}(e)))return e;throw new TS({uri:n})}),ES.apply(this,arguments)}function AS(){return(AS=(0,Ge.Z)(function*(t,{nft:n}){if("erc721"===n.namespace)return Al(t,{address:n.contractAddress,abi:[{name:"tokenURI",type:"function",stateMutability:"view",inputs:[{name:"tokenId",type:"uint256"}],outputs:[{name:"",type:"string"}]}],functionName:"tokenURI",args:[BigInt(n.tokenID)]});if("erc1155"===n.namespace)return Al(t,{address:n.contractAddress,abi:[{name:"uri",type:"function",stateMutability:"view",inputs:[{name:"_id",type:"uint256"}],outputs:[{name:"",type:"string"}]}],functionName:"uri",args:[BigInt(n.tokenID)]});throw new GGe({namespace:n.namespace})})).apply(this,arguments)}function IS(){return IS=(0,Ge.Z)(function*(t,{gatewayUrls:n,record:e}){return/eip155:/i.test(e)?function iZe(t,n){return DS.apply(this,arguments)}(t,{gatewayUrls:n,record:e}):SS({uri:e,gatewayUrls:n})}),IS.apply(this,arguments)}function DS(){return DS=(0,Ge.Z)(function*(t,{gatewayUrls:n,record:e}){const i=function eZe(t){let n=t;n.startsWith("did:nft:")&&(n=n.replace("did:nft:","").replace(/_/g,"/"));const[e,i,r]=n.split("/"),[s,a]=e.split(":"),[o,c]=i.split(":");if(!s||"eip155"!==s.toLowerCase())throw new _h({reason:"Only EIP-155 supported"});if(!a)throw new _h({reason:"Chain ID not found"});if(!c)throw new _h({reason:"Contract address not found"});if(!r)throw new _h({reason:"Token ID not found"});if(!o)throw new _h({reason:"ERC namespace not found"});return{chainID:parseInt(a),namespace:o.toLowerCase(),contractAddress:c,tokenID:r}}(e),r=yield function tZe(t,n){return AS.apply(this,arguments)}(t,{nft:i}),{uri:s,isOnChain:a,isEncoded:o}=HQ({uri:r,gatewayUrls:n});if(a&&(s.includes("data:application/json;base64,")||s.startsWith("{"))){const l=o?atob(s.replace("data:application/json;base64,","")):s;return SS({uri:VQ(JSON.parse(l)),gatewayUrls:n})}let c=i.tokenID;return"erc1155"===i.namespace&&(c=c.replace("0x","").padStart(64,"0")),function JGe(t){return kS.apply(this,arguments)}({gatewayUrls:n,uri:s.replace(/(?:0x)?{id}/,c)})}),DS.apply(this,arguments)}function FQ(t,n){return NS.apply(this,arguments)}function NS(){return(NS=(0,Ge.Z)(function*(t,{blockNumber:n,blockTag:e,name:i,key:r,gatewayUrls:s,strict:a,universalResolverAddress:o}){let c=o;if(!c){if(!t.chain)throw new Error("client chain not configured. universalResolverAddress is required.");c=(0,rh.L)({blockNumber:n,chain:t.chain,contract:"ensUniversalResolver"})}try{const l={address:c,abi:Sl.k3,functionName:"resolve",args:[(0,Qn.NC)(zv(i)),(0,El.R)({abi:Sl.nZ,functionName:"text",args:[Pv(i),r]})],blockNumber:n,blockTag:e},u=ri(t,Al,"readContract"),d=s?yield u({...l,args:[...l.args,s]}):yield u(l);if("0x"===d[0])return null;const h=(0,ih.k)({abi:Sl.nZ,functionName:"text",data:d[0]});return""===h?null:h}catch(l){if(a)throw l;if(wS(l,"resolve"))return null;throw l}})).apply(this,arguments)}function BQ(t,n){return RS.apply(this,arguments)}function RS(){return RS=(0,Ge.Z)(function*(t,{blockNumber:n,blockTag:e,assetGatewayUrls:i,name:r,gatewayUrls:s,strict:a,universalResolverAddress:o}){const c=yield ri(t,FQ,"getEnsText")({blockNumber:n,blockTag:e,key:"avatar",name:r,universalResolverAddress:o,gatewayUrls:s,strict:a});if(!c)return null;try{return yield function nZe(t,n){return IS.apply(this,arguments)}(t,{record:c,gatewayUrls:i})}catch{return null}}),RS.apply(this,arguments)}function UQ(t,n){return LS.apply(this,arguments)}function LS(){return(LS=(0,Ge.Z)(function*(t,{address:n,blockNumber:e,blockTag:i,gatewayUrls:r,strict:s,universalResolverAddress:a}){let o=a;if(!o){if(!t.chain)throw new Error("client chain not configured. universalResolverAddress is required.");o=(0,rh.L)({blockNumber:e,chain:t.chain,contract:"ensUniversalResolver"})}const c=`${n.toLowerCase().substring(2)}.addr.reverse`;try{const l={address:o,abi:Sl.du,functionName:"reverse",args:[(0,Qn.NC)(zv(c))],blockNumber:e,blockTag:i},u=ri(t,Al,"readContract"),[d,h]=r?yield u({...l,args:[...l.args,r]}):yield u(l);return n.toLowerCase()!==h.toLowerCase()?null:d}catch(l){if(s)throw l;if(wS(l,"reverse"))return null;throw l}})).apply(this,arguments)}function PS(){return(PS=(0,Ge.Z)(function*(t,{blockNumber:n,blockTag:e,name:i,universalResolverAddress:r}){let s=r;if(!s){if(!t.chain)throw new Error("client chain not configured. universalResolverAddress is required.");s=(0,rh.L)({blockNumber:n,chain:t.chain,contract:"ensUniversalResolver"})}const[a]=yield ri(t,Al,"readContract")({address:s,abi:[{inputs:[{type:"bytes"}],name:"findResolver",outputs:[{type:"address"},{type:"bytes32"}],stateMutability:"view",type:"function"}],functionName:"findResolver",args:[(0,Qn.NC)(zv(i))],blockNumber:n,blockTag:e});return a})).apply(this,arguments)}function Ov(t,{method:n}){const e={};return"fallback"===t.transport.type&&t.transport.onResponse?.(({method:i,response:r,status:s,transport:a})=>{"success"===s&&n===i&&(e[r]=a.request)}),i=>e[i]||t.request}function zS(){return(zS=(0,Ge.Z)(function*(t){const n=Ov(t,{method:"eth_newBlockFilter"}),e=yield t.request({method:"eth_newBlockFilter"});return{id:e,request:n(e),type:"block"}})).apply(this,arguments)}class aZe extends Bs.G{constructor(n){super(`Filter type "${n}" is not supported.`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"FilterTypeNotSupportedError"})}}var $Q=$(8755),bh=$(2910),jQ=$(6537),WQ=$(930);const qQ="/docs/contract/encodeEventTopics";function wh(t){const{abi:n,eventName:e,args:i}=t;let r=n[0];if(e){const c=(0,WQ.mE)({abi:n,name:e});if(!c)throw new bs.mv(e,{docsPath:qQ});r=c}if("event"!==r.type)throw new bs.mv(void 0,{docsPath:qQ});const s=(0,jQ.t)(r),a=(0,$Q.n)(s);let o=[];if(i&&"inputs"in r){const c=r.inputs?.filter(u=>"indexed"in u&&u.indexed),l=Array.isArray(i)?i:Object.values(i).length>0?c?.map(u=>i[u.name])??[]:[];l.length>0&&(o=c?.map((u,d)=>Array.isArray(l[d])?l[d].map((h,y)=>GQ({param:u,value:l[d][y]})):l[d]?GQ({param:u,value:l[d]}):null)??[])}return[a,...o]}function GQ({param:t,value:n}){if("string"===t.type||"bytes"===t.type)return(0,r2.w)((0,Sn.O0)(n));if("tuple"===t.type||t.type.match(/^(.*)\[(\d+)?\]$/))throw new aZe(t.type);return(0,bh.E)([t],[n])}function ZQ(t,n){return OS.apply(this,arguments)}function OS(){return(OS=(0,Ge.Z)(function*(t,n){const{address:e,abi:i,args:r,eventName:s,fromBlock:a,strict:o,toBlock:c}=n,l=Ov(t,{method:"eth_newFilter"}),u=s?wh({abi:i,args:r,eventName:s}):void 0,d=yield t.request({method:"eth_newFilter",params:[{address:e,fromBlock:"bigint"==typeof a?(0,Qn.eC)(a):a,toBlock:"bigint"==typeof c?(0,Qn.eC)(c):c,topics:u}]});return{abi:i,args:r,eventName:s,id:d,request:l(d),strict:!!o,type:"event"}})).apply(this,arguments)}function YQ(t){return HS.apply(this,arguments)}function HS(){return(HS=(0,Ge.Z)(function*(t,{address:n,args:e,event:i,events:r,fromBlock:s,strict:a,toBlock:o}={}){const c=r??(i?[i]:void 0),l=Ov(t,{method:"eth_newFilter"});let u=[];c&&(u=[c.flatMap(h=>wh({abi:[h],eventName:h.name,args:e}))],i&&(u=u[0]));const d=yield t.request({method:"eth_newFilter",params:[{address:n,fromBlock:"bigint"==typeof s?(0,Qn.eC)(s):s,toBlock:"bigint"==typeof o?(0,Qn.eC)(o):o,...u.length?{topics:u}:{}}]});return{abi:c,args:e,eventName:i?i.name:void 0,fromBlock:s,id:d,request:l(d),strict:!!a,toBlock:o,type:"event"}})).apply(this,arguments)}function KQ(t){return VS.apply(this,arguments)}function VS(){return(VS=(0,Ge.Z)(function*(t){const n=Ov(t,{method:"eth_newPendingTransactionFilter"}),e=yield t.request({method:"eth_newPendingTransactionFilter"});return{id:e,request:n(e),type:"transaction"}})).apply(this,arguments)}var oZe=$(8004),Hv=$(9077),W3=$(8284);class cZe extends Bs.G{constructor(n,{account:e,docsPath:i,chain:r,data:s,gas:a,gasPrice:o,maxFeePerGas:c,maxPriorityFeePerGas:l,nonce:u,to:d,value:h}){const y=(0,W3.xr)({from:e?.address,to:d,value:typeof h<"u"&&`${(0,oZe.d)(h)} ${r?.nativeCurrency?.symbol||"ETH"}`,data:s,gas:a,gasPrice:typeof o<"u"&&`${(0,Hv.o)(o)} gwei`,maxFeePerGas:typeof c<"u"&&`${(0,Hv.o)(c)} gwei`,maxPriorityFeePerGas:typeof l<"u"&&`${(0,Hv.o)(l)} gwei`,nonce:u});super(n.shortMessage,{cause:n,docsPath:i,metaMessages:[...n.metaMessages?[...n.metaMessages," "]:[],"Estimate Gas Arguments:",y].filter(Boolean)}),Object.defineProperty(this,"cause",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"EstimateGasExecutionError"}),this.cause=n}}var XQ=$(7354),QQ=$(2917),JQ=$(7603),eJ=$(7369),FS=$(9056);class uZe extends Bs.G{constructor(){super("`baseFeeMultiplier` must be greater than 1."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"BaseFeeScalarError"})}}class BS extends Bs.G{constructor(){super("Chain does not support EIP-1559 fees."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"Eip1559FeesNotSupportedError"})}}class dZe extends Bs.G{constructor({maxPriorityFeePerGas:n}){super(`\`maxFeePerGas\` cannot be less than the \`maxPriorityFeePerGas\` (${(0,Hv.o)(n)} gwei).`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"MaxFeePerGasTooLowError"})}}var $2=$(9415);class tJ extends Bs.G{constructor({blockHash:n,blockNumber:e}){let i="Block";n&&(i=`Block at hash "${n}"`),e&&(i=`Block at number "${e}"`),super(`${i} could not be found.`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"BlockNotFoundError"})}}const nJ={"0x0":"legacy","0x1":"eip2930","0x2":"eip1559","0x3":"eip4844"};function iJ(t){const n={...t,blockHash:t.blockHash?t.blockHash:null,blockNumber:t.blockNumber?BigInt(t.blockNumber):null,chainId:t.chainId?(0,$2.ly)(t.chainId):void 0,gas:t.gas?BigInt(t.gas):void 0,gasPrice:t.gasPrice?BigInt(t.gasPrice):void 0,maxFeePerBlobGas:t.maxFeePerBlobGas?BigInt(t.maxFeePerBlobGas):void 0,maxFeePerGas:t.maxFeePerGas?BigInt(t.maxFeePerGas):void 0,maxPriorityFeePerGas:t.maxPriorityFeePerGas?BigInt(t.maxPriorityFeePerGas):void 0,nonce:t.nonce?(0,$2.ly)(t.nonce):void 0,to:t.to?t.to:null,transactionIndex:t.transactionIndex?Number(t.transactionIndex):null,type:t.type?nJ[t.type]:void 0,typeHex:t.type?t.type:void 0,value:t.value?BigInt(t.value):void 0,v:t.v?BigInt(t.v):void 0};return n.yParity=(()=>{if(t.yParity)return Number(t.yParity);if("bigint"==typeof n.v){if(0n===n.v||27n===n.v)return 0;if(1n===n.v||28n===n.v)return 1;if(n.v>=35n)return n.v%2n===0n?1:0}})(),"legacy"===n.type&&(delete n.accessList,delete n.maxFeePerBlobGas,delete n.maxFeePerGas,delete n.maxPriorityFeePerGas,delete n.yParity),"eip2930"===n.type&&(delete n.maxFeePerBlobGas,delete n.maxFeePerGas,delete n.maxPriorityFeePerGas),"eip1559"===n.type&&delete n.maxFeePerBlobGas,n}function rJ(t){const n=t.transactions?.map(e=>"string"==typeof e?e:iJ(e));return{...t,baseFeePerGas:t.baseFeePerGas?BigInt(t.baseFeePerGas):null,blobGasUsed:t.blobGasUsed?BigInt(t.blobGasUsed):void 0,difficulty:t.difficulty?BigInt(t.difficulty):void 0,excessBlobGas:t.excessBlobGas?BigInt(t.excessBlobGas):void 0,gasLimit:t.gasLimit?BigInt(t.gasLimit):void 0,gasUsed:t.gasUsed?BigInt(t.gasUsed):void 0,hash:t.hash?t.hash:null,logsBloom:t.logsBloom?t.logsBloom:null,nonce:t.nonce?t.nonce:null,number:t.number?BigInt(t.number):null,size:t.size?BigInt(t.size):void 0,timestamp:t.timestamp?BigInt(t.timestamp):void 0,transactions:n,totalDifficulty:t.totalDifficulty?BigInt(t.totalDifficulty):null}}function q3(t){return US.apply(this,arguments)}function US(){return(US=(0,Ge.Z)(function*(t,{blockHash:n,blockNumber:e,blockTag:i,includeTransactions:r}={}){const s=i??"latest",a=r??!1,o=void 0!==e?(0,Qn.eC)(e):void 0;let c=null;if(c=n?yield t.request({method:"eth_getBlockByHash",params:[n,a]}):yield t.request({method:"eth_getBlockByNumber",params:[o||s,a]}),!c)throw new tJ({blockHash:n,blockNumber:e});return(t.chain?.formatters?.block?.format||rJ)(c)})).apply(this,arguments)}function $S(t){return jS.apply(this,arguments)}function jS(){return(jS=(0,Ge.Z)(function*(t){const n=yield t.request({method:"eth_gasPrice"});return BigInt(n)})).apply(this,arguments)}function WS(){return(WS=(0,Ge.Z)(function*(t,n){return sJ(t,n)})).apply(this,arguments)}function sJ(t,n){return qS.apply(this,arguments)}function qS(){return(qS=(0,Ge.Z)(function*(t,n){const{block:e,chain:i=t.chain,request:r}=n||{};if("function"==typeof i?.fees?.defaultPriorityFee){const s=e||(yield ri(t,q3,"getBlock")({}));return i.fees.defaultPriorityFee({block:s,client:t,request:r})}if(typeof i?.fees?.defaultPriorityFee<"u")return i?.fees?.defaultPriorityFee;try{const s=yield t.request({method:"eth_maxPriorityFeePerGas"});return(0,$2.y_)(s)}catch{const[s,a]=yield Promise.all([e?Promise.resolve(e):ri(t,q3,"getBlock")({}),ri(t,$S,"getGasPrice")({})]);if("bigint"!=typeof s.baseFeePerGas)throw new BS;const o=a-s.baseFeePerGas;return o<0n?0n:o}})).apply(this,arguments)}function aJ(t,n){return GS.apply(this,arguments)}function GS(){return(GS=(0,Ge.Z)(function*(t,n){return ZS(t,n)})).apply(this,arguments)}function ZS(t,n){return YS.apply(this,arguments)}function YS(){return(YS=(0,Ge.Z)(function*(t,n){const{block:e,chain:i=t.chain,request:r,type:s="eip1559"}=n||{},a=yield(0,Ge.Z)(function*(){return"function"==typeof i?.fees?.baseFeeMultiplier?i.fees.baseFeeMultiplier({block:e,client:t,request:r}):i?.fees?.baseFeeMultiplier??1.2})();if(a<1)throw new uZe;const c=10**(a.toString().split(".")[1]?.length??0),l=h=>h*BigInt(Math.ceil(a*c))/BigInt(c),u=e||(yield ri(t,q3,"getBlock")({}));if("function"==typeof i?.fees?.estimateFeesPerGas){const h=yield i.fees.estimateFeesPerGas({block:e,client:t,multiply:l,request:r,type:s});if(null!==h)return h}if("eip1559"===s){if("bigint"!=typeof u.baseFeePerGas)throw new BS;const h="bigint"==typeof r?.maxPriorityFeePerGas?r.maxPriorityFeePerGas:yield sJ(t,{block:u,chain:i,request:r}),y=l(u.baseFeePerGas);return{maxFeePerGas:r?.maxFeePerGas??y+h,maxPriorityFeePerGas:h}}return{gasPrice:r?.gasPrice??l(yield ri(t,$S,"getGasPrice")({}))}})).apply(this,arguments)}function oJ(t,n){return KS.apply(this,arguments)}function KS(){return(KS=(0,Ge.Z)(function*(t,{address:n,blockTag:e="latest",blockNumber:i}){const r=yield t.request({method:"eth_getTransactionCount",params:[n,i?(0,Qn.eC)(i):e]});return(0,$2.ly)(r)})).apply(this,arguments)}function cJ(t){const{kzg:n}=t,e=t.to??("string"==typeof t.blobs[0]?"hex":"bytes"),i="string"==typeof t.blobs[0]?t.blobs.map(s=>(0,Sn.nr)(s)):t.blobs,r=[];for(const s of i)r.push(Uint8Array.from(n.blobToKzgCommitment(s)));return"bytes"===e?r:r.map(s=>(0,Qn.ci)(s))}function lJ(t){const{kzg:n}=t,e=t.to??("string"==typeof t.blobs[0]?"hex":"bytes"),i="string"==typeof t.blobs[0]?t.blobs.map(a=>(0,Sn.nr)(a)):t.blobs,r="string"==typeof t.commitments[0]?t.commitments.map(a=>(0,Sn.nr)(a)):t.commitments,s=[];for(let a=0;a<i.length;a++)s.push(Uint8Array.from(n.computeBlobKzgProof(i[a],r[a])));return"bytes"===e?s:s.map(a=>(0,Qn.ci)(a))}var XS=$(3284),Oa=$(3130);class pZe extends Oa.kb{constructor(n,e,i,r){super(),this.blockLen=n,this.outputLen=e,this.padOffset=i,this.isLE=r,this.finished=!1,this.length=0,this.pos=0,this.destroyed=!1,this.buffer=new Uint8Array(n),this.view=(0,Oa.GL)(this.buffer)}update(n){(0,XS.Gg)(this);const{view:e,buffer:i,blockLen:r}=this,s=(n=(0,Oa.O0)(n)).length;for(let a=0;a<s;){const o=Math.min(r-this.pos,s-a);if(o!==r)i.set(n.subarray(a,a+o),this.pos),this.pos+=o,a+=o,this.pos===r&&(this.process(e,0),this.pos=0);else{const c=(0,Oa.GL)(n);for(;r<=s-a;a+=r)this.process(c,a)}}return this.length+=n.length,this.roundClean(),this}digestInto(n){(0,XS.Gg)(this),(0,XS.J8)(n,this),this.finished=!0;const{buffer:e,view:i,blockLen:r,isLE:s}=this;let{pos:a}=this;e[a++]=128,this.buffer.subarray(a).fill(0),this.padOffset>r-a&&(this.process(i,0),a=0);for(let d=a;d<r;d++)e[d]=0;(function hZe(t,n,e,i){if("function"==typeof t.setBigUint64)return t.setBigUint64(n,e,i);const r=BigInt(32),s=BigInt(4294967295),a=Number(e>>r&s),o=Number(e&s),l=i?0:4;t.setUint32(n+(i?4:0),a,i),t.setUint32(n+l,o,i)})(i,r-8,BigInt(8*this.length),s),this.process(i,0);const o=(0,Oa.GL)(n),c=this.outputLen;if(c%4)throw new Error("_sha2: outputLen should be aligned to 32bit");const l=c/4,u=this.get();if(l>u.length)throw new Error("_sha2: outputLen bigger than state");for(let d=0;d<l;d++)o.setUint32(4*d,u[d],s)}digest(){const{buffer:n,outputLen:e}=this;this.digestInto(n);const i=n.slice(0,e);return this.destroy(),i}_cloneInto(n){n||(n=new this.constructor),n.set(...this.get());const{blockLen:e,buffer:i,length:r,finished:s,destroyed:a,pos:o}=this;return n.length=r,n.pos=o,n.finished=s,n.destroyed=a,r%e&&n.buffer.set(i),n}}const mZe=(t,n,e)=>t&n^~t&e,gZe=(t,n,e)=>t&n^t&e^n&e,vZe=new Uint32Array([1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298]),G3=new Uint32Array([1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225]),Z3=new Uint32Array(64);class yZe extends pZe{constructor(){super(64,32,8,!1),this.A=0|G3[0],this.B=0|G3[1],this.C=0|G3[2],this.D=0|G3[3],this.E=0|G3[4],this.F=0|G3[5],this.G=0|G3[6],this.H=0|G3[7]}get(){const{A:n,B:e,C:i,D:r,E:s,F:a,G:o,H:c}=this;return[n,e,i,r,s,a,o,c]}set(n,e,i,r,s,a,o,c){this.A=0|n,this.B=0|e,this.C=0|i,this.D=0|r,this.E=0|s,this.F=0|a,this.G=0|o,this.H=0|c}process(n,e){for(let d=0;d<16;d++,e+=4)Z3[d]=n.getUint32(e,!1);for(let d=16;d<64;d++){const h=Z3[d-15],y=Z3[d-2],I=(0,Oa.np)(h,7)^(0,Oa.np)(h,18)^h>>>3,D=(0,Oa.np)(y,17)^(0,Oa.np)(y,19)^y>>>10;Z3[d]=D+Z3[d-7]+I+Z3[d-16]|0}let{A:i,B:r,C:s,D:a,E:o,F:c,G:l,H:u}=this;for(let d=0;d<64;d++){const y=u+((0,Oa.np)(o,6)^(0,Oa.np)(o,11)^(0,Oa.np)(o,25))+mZe(o,c,l)+vZe[d]+Z3[d]|0,D=((0,Oa.np)(i,2)^(0,Oa.np)(i,13)^(0,Oa.np)(i,22))+gZe(i,r,s)|0;u=l,l=c,c=o,o=a+y|0,a=s,s=r,r=i,i=y+D|0}i=i+this.A|0,r=r+this.B|0,s=s+this.C|0,a=a+this.D|0,o=o+this.E|0,c=c+this.F|0,l=l+this.G|0,u=u+this.H|0,this.set(i,r,s,a,o,c,l,u)}roundClean(){Z3.fill(0)}destroy(){this.set(0,0,0,0,0,0,0,0),this.buffer.fill(0)}}const _Ze=(0,Oa.hE)(()=>new yZe);function wZe(t){const{commitment:n,version:e=1}=t,i=t.to??("string"==typeof n?"hex":"bytes"),r=function bZe(t,n){const e=n||"hex",i=_Ze((0,bd.v)(t,{strict:!1})?(0,Sn.O0)(t):t);return"bytes"===e?i:(0,Qn.NC)(i)}(n,"bytes");return r.set([e],0),"bytes"===i?r:(0,Qn.ci)(r)}const dJ=32,QS=4096,fJ=dJ*QS,hJ=6*fJ-1-1*QS*6;class xZe extends Bs.G{constructor({maxSize:n,size:e}){super("Blob size is too large.",{metaMessages:[`Max: ${n} bytes`,`Given: ${e} bytes`]}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"BlobSizeTooLargeError"})}}class TZe extends Bs.G{constructor(){super("Blob data must not be empty."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"EmptyBlobError"})}}var MZe=$(9995),Vv=$(4018);function JS(t){return eE.apply(this,arguments)}function eE(){return(eE=(0,Ge.Z)(function*(t){const n=yield t.request({method:"eth_chainId"});return(0,$2.ly)(n)})).apply(this,arguments)}const pJ=["blobVersionedHashes","chainId","fees","gas","nonce","type"];function tE(t,n){return nE.apply(this,arguments)}function nE(){return nE=(0,Ge.Z)(function*(t,n){const{account:e=t.account,blobs:i,chain:r,chainId:s,gas:a,kzg:o,nonce:c,parameters:l=pJ,type:u}=n,d=e?(0,kl.T)(e):void 0,h={...n,...d?{from:d?.address}:{}};let y;function I(){return D.apply(this,arguments)}function D(){return(D=(0,Ge.Z)(function*(){return y||(y=yield ri(t,q3,"getBlock")({blockTag:"latest"}),y)})).apply(this,arguments)}if((l.includes("blobVersionedHashes")||l.includes("sidecars"))&&i&&o){const V=cJ({blobs:i,kzg:o});if(l.includes("blobVersionedHashes")){const we=function CZe(t){const{commitments:n,version:e}=t,i=t.to??("string"==typeof n[0]?"hex":"bytes"),r=[];for(const s of n)r.push(wZe({commitment:s,to:i,version:e}));return r}({commitments:V,to:"hex"});h.blobVersionedHashes=we}if(l.includes("sidecars")){const Ce=function SZe(t){const{data:n,kzg:e,to:i}=t,r=t.blobs??function kZe(t){const n=t.to??("string"==typeof t.data?"hex":"bytes"),e="string"==typeof t.data?(0,Sn.nr)(t.data):t.data,i=(0,Vv.d)(e);if(!i)throw new TZe;if(i>hJ)throw new xZe({maxSize:hJ,size:i});const r=[];let s=!0,a=0;for(;s;){const o=(0,MZe.q)(new Uint8Array(fJ));let c=0;for(;c<QS;){const l=e.slice(a,a+(dJ-1));if(o.pushByte(0),o.pushBytes(l),l.length<31){o.pushByte(128),s=!1;break}c++,a+=31}r.push(o)}return r.map("bytes"===n?o=>o.bytes:o=>(0,Qn.ci)(o.bytes))}({data:n,to:i}),s=t.commitments??cJ({blobs:r,kzg:e,to:i}),a=t.proofs??lJ({blobs:r,commitments:s,kzg:e,to:i}),o=[];for(let c=0;c<r.length;c++)o.push({blob:r[c],commitment:s[c],proof:a[c]});return o}({blobs:i,commitments:V,proofs:lJ({blobs:i,commitments:V,kzg:o}),to:"hex"});h.sidecars=Ce}}if(l.includes("chainId")&&(h.chainId=r?r.id:typeof s<"u"?s:yield ri(t,JS,"getChainId")({})),l.includes("nonce")&&typeof c>"u"&&d&&(h.nonce=yield ri(t,oJ,"getTransactionCount")({address:d.address,blockTag:"pending"})),(l.includes("fees")||l.includes("type"))&&typeof u>"u")try{h.type=function EZe(t){if(t.type)return t.type;if(typeof t.blobs<"u"||typeof t.blobVersionedHashes<"u"||typeof t.maxFeePerBlobGas<"u"||typeof t.sidecars<"u")return"eip4844";if(typeof t.maxFeePerGas<"u"||typeof t.maxPriorityFeePerGas<"u")return"eip1559";if(typeof t.gasPrice<"u")return typeof t.accessList<"u"?"eip2930":"legacy";throw new W3.j3({transaction:t})}(h)}catch{const V=yield I();h.type="bigint"==typeof V?.baseFeePerGas?"eip1559":"legacy"}if(l.includes("fees"))if("eip1559"===h.type||"eip4844"===h.type){if(typeof h.maxFeePerGas>"u"||typeof h.maxPriorityFeePerGas>"u"){const V=yield I(),{maxFeePerGas:we,maxPriorityFeePerGas:Ce}=yield ZS(t,{block:V,chain:r,request:h});if(typeof n.maxPriorityFeePerGas>"u"&&n.maxFeePerGas&&n.maxFeePerGas<Ce)throw new dZe({maxPriorityFeePerGas:Ce});h.maxPriorityFeePerGas=Ce,h.maxFeePerGas=we}}else{if(typeof n.maxFeePerGas<"u"||typeof n.maxPriorityFeePerGas<"u")throw new BS;const V=yield I(),{gasPrice:we}=yield ZS(t,{block:V,chain:r,request:h,type:"legacy"});h.gasPrice=we}return l.includes("gas")&&typeof a>"u"&&(h.gas=yield ri(t,Ch,"estimateGas")({...h,account:d?{address:d.address,type:"json-rpc"}:void 0})),(0,FS.F)(h),delete h.parameters,h}),nE.apply(this,arguments)}function Ch(t,n){return iE.apply(this,arguments)}function iE(){return(iE=(0,Ge.Z)(function*(t,n){const e=n.account??t.account,i=e?(0,kl.T)(e):void 0;try{const{accessList:r,blobs:s,blobVersionedHashes:a,blockNumber:o,blockTag:c,data:l,gas:u,gasPrice:d,maxFeePerBlobGas:h,maxFeePerGas:y,maxPriorityFeePerGas:I,nonce:D,to:V,value:we,...Ce}=yield tE(t,{...n,parameters:"local"===i?.type?void 0:["blobVersionedHashes"]}),Fe=(o?(0,Qn.eC)(o):void 0)||c;(0,FS.F)(n);const qe=t.chain?.formatters?.transactionRequest?.format,dt=(qe||eJ.tG)({...(0,JQ.K)(Ce,{format:qe}),from:i?.address,accessList:r,blobs:s,blobVersionedHashes:a,data:l,gas:u,gasPrice:d,maxFeePerBlobGas:h,maxFeePerGas:y,maxPriorityFeePerGas:I,nonce:D,to:V,value:we}),mt=yield t.request({method:"eth_estimateGas",params:Fe?[dt,Fe]:[dt]});return BigInt(mt)}catch(r){throw function lZe(t,{docsPath:n,...e}){const i=(()=>{const r=(0,QQ.k)(t,e);return r instanceof XQ.cj?t:r})();return new cZe(i,{docsPath:n,...e})}(r,{...n,account:i,chain:t.chain})}})).apply(this,arguments)}function rE(){return(rE=(0,Ge.Z)(function*(t,n){const{abi:e,address:i,args:r,functionName:s,...a}=n,o=(0,El.R)({abi:e,args:r,functionName:s});try{return yield ri(t,Ch,"estimateGas")({data:o,to:i,...a})}catch(c){const l=a.account?(0,kl.T)(a.account):void 0;throw vh(c,{abi:e,address:i,args:r,docsPath:"/docs/contract/estimateContractGas",functionName:s,sender:l?.address})}})).apply(this,arguments)}function mJ(t,n){return sE.apply(this,arguments)}function sE(){return(sE=(0,Ge.Z)(function*(t,{address:n,blockNumber:e,blockTag:i="latest"}){const r=e?(0,Qn.eC)(e):void 0,s=yield t.request({method:"eth_getBalance",params:[n,r||i]});return BigInt(s)})).apply(this,arguments)}function aE(){return(aE=(0,Ge.Z)(function*(t){const n=yield t.request({method:"eth_blobBaseFee"});return BigInt(n)})).apply(this,arguments)}const DZe=new Map,NZe=new Map;function oE(){return(oE=(0,Ge.Z)(function*(t,{cacheKey:n,cacheTime:e=1/0}){const i=function RZe(t){const n=(r,s)=>({clear:()=>s.delete(r),get:()=>s.get(r),set:a=>s.set(r,a)}),e=n(t,DZe),i=n(t,NZe);return{clear:()=>{e.clear(),i.clear()},promise:e,response:i}}(n),r=i.response.get();if(r&&e>0&&(new Date).getTime()-r.created.getTime()<e)return r.data;let s=i.promise.get();s||(s=t(),i.promise.set(s));try{const a=yield s;return i.response.set({created:new Date,data:a}),a}finally{i.promise.clear()}})).apply(this,arguments)}const gJ=t=>`blockNumber.${t}`;function xh(t){return cE.apply(this,arguments)}function cE(){return cE=(0,Ge.Z)(function*(t,{cacheTime:n=t.cacheTime}={}){const e=yield function LZe(t,n){return oE.apply(this,arguments)}(()=>t.request({method:"eth_blockNumber"}),{cacheKey:gJ(t.uid),cacheTime:n});return BigInt(e)}),cE.apply(this,arguments)}function lE(){return(lE=(0,Ge.Z)(function*(t,{blockHash:n,blockNumber:e,blockTag:i="latest"}={}){const r=void 0!==e?(0,Qn.eC)(e):void 0;let s;return s=n?yield t.request({method:"eth_getBlockTransactionCountByHash",params:[n]}):yield t.request({method:"eth_getBlockTransactionCountByNumber",params:[r||i]}),(0,$2.ly)(s)})).apply(this,arguments)}function uE(){return(uE=(0,Ge.Z)(function*(t,{address:n,blockNumber:e,blockTag:i="latest"}){const r=void 0!==e?(0,Qn.eC)(e):void 0,s=yield t.request({method:"eth_getCode",params:[n,r||i]});if("0x"!==s)return s})).apply(this,arguments)}var OZe=$(2380),vJ=$(5383);const yJ="/docs/contract/decodeEventLog";function dE(t){const{abi:n,data:e,strict:i,topics:r}=t,s=i??!0,[a,...o]=r;if(!a)throw new bs.FM({docsPath:yJ});const c=n.find(D=>"event"===D.type&&a===(0,$Q.n)((0,jQ.t)(D)));if(!c||!("name"in c)||"event"!==c.type)throw new bs.lC(a,{docsPath:yJ});const{name:l,inputs:u}=c,d=u?.some(D=>!("name"in D&&D.name));let h=d?[]:{};const y=u.filter(D=>"indexed"in D&&D.indexed);for(let D=0;D<y.length;D++){const V=y[D],we=o[D];if(!we)throw new bs.Gy({abiItem:c,param:V});h[d?D:V.name||D]=HZe({param:V,value:we})}const I=u.filter(D=>!("indexed"in D&&D.indexed));if(I.length>0)if(e&&"0x"!==e)try{const D=(0,vJ.r)(I,e);if(D)if(d)h=[...h,...D];else for(let V=0;V<I.length;V++)h[I[V].name]=D[V]}catch(D){if(s)throw D instanceof bs.xB||D instanceof OZe.lQ?new bs.SM({abiItem:c,data:e,params:I,size:(0,Vv.d)(e)}):D}else if(s)throw new bs.SM({abiItem:c,data:"0x",params:I,size:0});return{eventName:l,args:Object.values(h).length>0?h:void 0}}function HZe({param:t,value:n}){return"string"===t.type||"bytes"===t.type||"tuple"===t.type||t.type.match(/^(.*)\[(\d+)?\]$/)?n:((0,vJ.r)([t],n)||[])[0]}function fE({abi:t,eventName:n,logs:e,strict:i=!0}){return e.map(r=>{try{const s=dE({...r,abi:t,strict:i});return n&&!n.includes(s.eventName)?null:{...s,...r}}catch(s){let a,o;if(s instanceof bs.lC)return null;if(s instanceof bs.SM||s instanceof bs.Gy){if(i)return null;a=s.abiItem.name,o=s.abiItem.inputs?.some(c=>!("name"in c&&c.name))}return{...r,args:o?[]:{},eventName:a}}}).filter(Boolean)}function Y3(t,{args:n,eventName:e}={}){return{...t,blockHash:t.blockHash?t.blockHash:null,blockNumber:t.blockNumber?BigInt(t.blockNumber):null,logIndex:t.logIndex?Number(t.logIndex):null,transactionHash:t.transactionHash?t.transactionHash:null,transactionIndex:t.transactionIndex?Number(t.transactionIndex):null,...e?{args:n,eventName:e}:{}}}function hE(t){return pE.apply(this,arguments)}function pE(){return(pE=(0,Ge.Z)(function*(t,{address:n,blockHash:e,fromBlock:i,toBlock:r,event:s,events:a,args:o,strict:c}={}){const l=c??!1,u=a??(s?[s]:void 0);let h,d=[];u&&(d=[u.flatMap(I=>wh({abi:[I],eventName:I.name,args:o}))],s&&(d=d[0])),h=e?yield t.request({method:"eth_getLogs",params:[{address:n,topics:d,blockHash:e}]}):yield t.request({method:"eth_getLogs",params:[{address:n,topics:d,fromBlock:"bigint"==typeof i?(0,Qn.eC)(i):i,toBlock:"bigint"==typeof r?(0,Qn.eC)(r):r}]});const y=h.map(I=>Y3(I));return u?fE({abi:u,logs:y,strict:l}):y})).apply(this,arguments)}function _J(t,n){return mE.apply(this,arguments)}function mE(){return(mE=(0,Ge.Z)(function*(t,n){const{abi:e,address:i,args:r,blockHash:s,eventName:a,fromBlock:o,toBlock:c,strict:l}=n,u=a?(0,WQ.mE)({abi:e,name:a}):void 0,d=u?void 0:e.filter(h=>"event"===h.type);return ri(t,hE,"getLogs")({address:i,args:r,blockHash:s,event:u,events:d,fromBlock:o,toBlock:c,strict:l})})).apply(this,arguments)}function gE(){return(gE=(0,Ge.Z)(function*(t,{blockCount:n,blockNumber:e,blockTag:i="latest",rewardPercentiles:r}){const s=e?(0,Qn.eC)(e):void 0;return function VZe(t){return{baseFeePerGas:t.baseFeePerGas.map(n=>BigInt(n)),gasUsedRatio:t.gasUsedRatio,oldestBlock:BigInt(t.oldestBlock),reward:t.reward?.map(n=>n.map(e=>BigInt(e)))}}(yield t.request({method:"eth_feeHistory",params:[(0,Qn.eC)(n),s||i,r]}))})).apply(this,arguments)}function Fv(t,n){return vE.apply(this,arguments)}function vE(){return(vE=(0,Ge.Z)(function*(t,{filter:n}){const e="strict"in n&&n.strict,i=yield n.request({method:"eth_getFilterChanges",params:[n.id]});if("string"==typeof i[0])return i;const r=i.map(s=>Y3(s));return"abi"in n&&n.abi?fE({abi:n.abi,logs:r,strict:e}):r})).apply(this,arguments)}function yE(){return(yE=(0,Ge.Z)(function*(t,{filter:n}){const e=n.strict??!1,r=(yield n.request({method:"eth_getFilterLogs",params:[n.id]})).map(s=>Y3(s));return n.abi?fE({abi:n.abi,logs:r,strict:e}):r})).apply(this,arguments)}function UZe(t){return t.map(n=>({...n,value:BigInt(n.value)}))}function _E(){return(_E=(0,Ge.Z)(function*(t,{address:n,blockNumber:e,blockTag:i,storageKeys:r}){const s=i??"latest",a=void 0!==e?(0,Qn.eC)(e):void 0;return function $Ze(t){return{...t,balance:t.balance?BigInt(t.balance):void 0,nonce:t.nonce?(0,$2.ly)(t.nonce):void 0,storageProof:t.storageProof?UZe(t.storageProof):void 0}}(yield t.request({method:"eth_getProof",params:[n,r,a||s]}))})).apply(this,arguments)}function bE(){return(bE=(0,Ge.Z)(function*(t,{address:n,blockNumber:e,blockTag:i="latest",slot:r}){const s=void 0!==e?(0,Qn.eC)(e):void 0;return yield t.request({method:"eth_getStorageAt",params:[n,r,s||i]})})).apply(this,arguments)}function Bv(t,n){return wE.apply(this,arguments)}function wE(){return(wE=(0,Ge.Z)(function*(t,{blockHash:n,blockNumber:e,blockTag:i,hash:r,index:s}){const a=i||"latest",o=void 0!==e?(0,Qn.eC)(e):void 0;let c=null;if(r?c=yield t.request({method:"eth_getTransactionByHash",params:[r]}):n?c=yield t.request({method:"eth_getTransactionByBlockHashAndIndex",params:[n,(0,Qn.eC)(s)]}):(o||a)&&(c=yield t.request({method:"eth_getTransactionByBlockNumberAndIndex",params:[o||a,(0,Qn.eC)(s)]})),!c)throw new W3.Bh({blockHash:n,blockNumber:e,blockTag:a,hash:r,index:s});return(t.chain?.formatters?.transaction?.format||iJ)(c)})).apply(this,arguments)}function CE(){return(CE=(0,Ge.Z)(function*(t,{hash:n,transactionReceipt:e}){const[i,r]=yield Promise.all([ri(t,xh,"getBlockNumber")({}),n?ri(t,Bv,"getBlockNumber")({hash:n}):void 0]),s=e?.blockNumber||r?.blockNumber;return s?i-s+1n:0n})).apply(this,arguments)}const GZe={"0x0":"reverted","0x1":"success"};function ZZe(t){const n={...t,blockNumber:t.blockNumber?BigInt(t.blockNumber):null,contractAddress:t.contractAddress?t.contractAddress:null,cumulativeGasUsed:t.cumulativeGasUsed?BigInt(t.cumulativeGasUsed):null,effectiveGasPrice:t.effectiveGasPrice?BigInt(t.effectiveGasPrice):null,gasUsed:t.gasUsed?BigInt(t.gasUsed):null,logs:t.logs?t.logs.map(e=>Y3(e)):null,to:t.to?t.to:null,transactionIndex:t.transactionIndex?(0,$2.ly)(t.transactionIndex):null,status:t.status?GZe[t.status]:null,type:t.type?nJ[t.type]||t.type:null};return t.blobGasPrice&&(n.blobGasPrice=BigInt(t.blobGasPrice)),t.blobGasUsed&&(n.blobGasUsed=BigInt(t.blobGasUsed)),n}function xE(t,n){return TE.apply(this,arguments)}function TE(){return(TE=(0,Ge.Z)(function*(t,{hash:n}){const e=yield t.request({method:"eth_getTransactionReceipt",params:[n]});if(!e)throw new W3.Yb({hash:n});return(t.chain?.formatters?.transactionReceipt?.format||ZZe)(e)})).apply(this,arguments)}function bJ(t,n){return ME.apply(this,arguments)}function ME(){return(ME=(0,Ge.Z)(function*(t,n){const{allowFailure:e=!0,batchSize:i,blockNumber:r,blockTag:s,multicallAddress:a,stateOverride:o}=n,c=n.contracts,l=i??("object"==typeof t.batch?.multicall&&t.batch.multicall.batchSize||1024);let u=a;if(!u){if(!t.chain)throw new Error("client chain not configured. multicallAddress is required.");u=(0,rh.L)({blockNumber:r,chain:t.chain,contract:"multicall3"})}const d=[[]];let h=0,y=0;for(let V=0;V<c.length;V++){const{abi:we,address:Ce,args:Ve,functionName:Fe}=c[V];try{const qe=(0,El.R)({abi:we,args:Ve,functionName:Fe});y+=(qe.length-2)/2,l>0&&y>l&&d[h].length>0&&(h++,y=(qe.length-2)/2,d[h]=[]),d[h]=[...d[h],{allowFailure:!0,callData:qe,target:Ce}]}catch(qe){const nt=vh(qe,{abi:we,address:Ce,args:Ve,docsPath:"/docs/contract/multicall",functionName:Fe});if(!e)throw nt;d[h]=[...d[h],{allowFailure:!0,callData:"0x",target:Ce}]}}const I=yield Promise.allSettled(d.map(V=>ri(t,Al,"readContract")({abi:Sl.F8,address:u,args:[V],blockNumber:r,blockTag:s,functionName:"aggregate3",stateOverride:o}))),D=[];for(let V=0;V<I.length;V++){const we=I[V];if("rejected"===we.status){if(!e)throw we.reason;for(let Ve=0;Ve<d[V].length;Ve++)D.push({status:"failure",error:we.reason,result:void 0});continue}const Ce=we.value;for(let Ve=0;Ve<Ce.length;Ve++){const{returnData:Fe,success:qe}=Ce[Ve],{callData:nt}=d[V][Ve],{abi:dt,address:mt,functionName:Et,args:Bt}=c[D.length];try{if("0x"===nt)throw new bs.wb;if(!qe)throw new Sc.VQ({data:Fe});const tn=(0,ih.k)({abi:dt,args:Bt,data:Fe,functionName:Et});D.push(e?{result:tn,status:"success"}:tn)}catch(tn){const on=vh(tn,{abi:dt,address:mt,args:Bt,docsPath:"/docs/contract/multicall",functionName:Et});if(!e)throw on;D.push({error:on,result:void 0,status:"failure"})}}}if(D.length!==c.length)throw new Bs.G("multicall results mismatch");return D})).apply(this,arguments)}function wJ(t,n){return kE.apply(this,arguments)}function kE(){return(kE=(0,Ge.Z)(function*(t,n){const{abi:e,address:i,args:r,dataSuffix:s,functionName:a,...o}=n,c=o.account?(0,kl.T)(o.account):t.account,l=(0,El.R)({abi:e,args:r,functionName:a});try{const{data:u}=yield ri(t,yh.RE,"call")({batch:!1,data:`${l}${s?s.replace("0x",""):""}`,to:i,...o,account:c});return{result:(0,ih.k)({abi:e,args:r,functionName:a,data:u||"0x"}),request:{abi:e.filter(y=>"name"in y&&y.name===n.functionName),address:i,args:r,dataSuffix:s,functionName:a,...o,account:c}}}catch(u){throw vh(u,{abi:e,address:i,args:r,docsPath:"/docs/contract/simulateContract",functionName:a,sender:c?.address})}})).apply(this,arguments)}function Uv(t,n){return SE.apply(this,arguments)}function SE(){return(SE=(0,Ge.Z)(function*(t,{filter:n}){return n.request({method:"eth_uninstallFilter",params:[n.id]})})).apply(this,arguments)}const YZe="\x19Ethereum Signed Message:\n",XZe="0x60806040523480156200001157600080fd5b50604051620007003803806200070083398101604081905262000034916200056f565b6000620000438484846200004f565b9050806000526001601ff35b600080846001600160a01b0316803b806020016040519081016040528181526000908060200190933c90507f6492649264926492649264926492649264926492649264926492649264926492620000a68462000451565b036200021f57600060608085806020019051810190620000c79190620005ce565b8651929550909350915060000362000192576000836001600160a01b031683604051620000f5919062000643565b6000604051808303816000865af19150503d806000811462000134576040519150601f19603f3d011682016040523d82523d6000602084013e62000139565b606091505b5050905080620001905760405162461bcd60e51b815260206004820152601e60248201527f5369676e617475726556616c696461746f723a206465706c6f796d656e74000060448201526064015b60405180910390fd5b505b604051630b135d3f60e11b808252906001600160a01b038a1690631626ba7e90620001c4908b90869060040162000661565b602060405180830381865afa158015620001e2573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906200020891906200069d565b6001600160e01b031916149450505050506200044a565b805115620002b157604051630b135d3f60e11b808252906001600160a01b03871690631626ba7e9062000259908890889060040162000661565b602060405180830381865afa15801562000277573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906200029d91906200069d565b6001600160e01b031916149150506200044a565b8251604114620003195760405162461bcd60e51b815260206004820152603a6024820152600080516020620006e083398151915260448201527f3a20696e76616c6964207369676e6174757265206c656e677468000000000000606482015260840162000187565b620003236200046b565b506020830151604080850151855186939260009185919081106200034b576200034b620006c9565b016020015160f81c9050601b81148015906200036b57508060ff16601c14155b15620003cf5760405162461bcd60e51b815260206004820152603b6024820152600080516020620006e083398151915260448201527f3a20696e76616c6964207369676e617475726520762076616c75650000000000606482015260840162000187565b6040805160008152602081018083528a905260ff83169181019190915260608101849052608081018390526001600160a01b038a169060019060a0016020604051602081039080840390855afa1580156200042e573d6000803e3d6000fd5b505050602060405103516001600160a01b031614955050505050505b9392505050565b60006020825110156200046357600080fd5b508051015190565b60405180606001604052806003906020820280368337509192915050565b6001600160a01b03811681146200049f57600080fd5b50565b634e487b7160e01b600052604160045260246000fd5b60005b83811015620004d5578181015183820152602001620004bb565b50506000910152565b600082601f830112620004f057600080fd5b81516001600160401b03808211156200050d576200050d620004a2565b604051601f8301601f19908116603f01168101908282118183101715620005385762000538620004a2565b816040528381528660208588010111156200055257600080fd5b62000565846020830160208901620004b8565b9695505050505050565b6000806000606084860312156200058557600080fd5b8351620005928162000489565b6020850151604086015191945092506001600160401b03811115620005b657600080fd5b620005c486828701620004de565b9150509250925092565b600080600060608486031215620005e457600080fd5b8351620005f18162000489565b60208501519093506001600160401b03808211156200060f57600080fd5b6200061d87838801620004de565b935060408601519150808211156200063457600080fd5b50620005c486828701620004de565b6000825162000657818460208701620004b8565b9190910192915050565b828152604060208201526000825180604084015262000688816060850160208701620004b8565b601f01601f1916919091016060019392505050565b600060208284031215620006b057600080fd5b81516001600160e01b0319811681146200044a57600080fd5b634e487b7160e01b600052603260045260246000fdfe5369676e617475726556616c696461746f72237265636f7665725369676e6572";BigInt(0),BigInt(1),BigInt(2);const IE="/docs/contract/encodeDeployData";function aYe(t){const{abi:n,args:e,bytecode:i}=t;if(!e||0===e.length)return i;const r=n.find(a=>"type"in a&&"constructor"===a.type);if(!r)throw new bs.fM({docsPath:IE});if(!("inputs"in r))throw new bs.cO({docsPath:IE});if(!r.inputs||0===r.inputs.length)throw new bs.cO({docsPath:IE});const s=(0,bh.E)(r.inputs,e);return(0,Ec.SM)([i,s])}function kJ(t,n){return DE.apply(this,arguments)}function DE(){return(DE=(0,Ge.Z)(function*(t,{address:n,hash:e,signature:i,...r}){const s=(0,bd.v)(i)?i:(0,Qn.NC)(i);try{const{data:a}=yield ri(t,yh.RE,"call")({data:aYe({abi:Sl.$o,args:[n,e,s],bytecode:XZe}),...r});return function sYe(t,n){return function iYe(t,n){if(t.length!==n.length)return!1;for(let e=0;e<t.length;e++)if(t[e]!==n[e])return!1;return!0}((0,bd.v)(t)?(0,Sn.O0)(t):t,(0,bd.v)(n)?(0,Sn.O0)(n):n)}(a??"0x0","0x1")}catch(a){if(a instanceof Sc.cg)return!1;throw a}})).apply(this,arguments)}function NE(){return(NE=(0,Ge.Z)(function*(t,{address:n,message:e,signature:i,...r}){const s=function KZe(t,n){const e="string"==typeof t?(0,Sn.qX)(t):t.raw instanceof Uint8Array?t.raw:(0,Sn.O0)(t.raw),i=(0,Sn.qX)(`${YZe}${e.length}`);return(0,r2.w)((0,Ec.zo)([i,e]),n)}(e);return kJ(t,{address:n,hash:s,signature:i,...r})})).apply(this,arguments)}var cYe=$(8355);const lYe=/^bytes([1-9]|1[0-9]|2[0-9]|3[0-2])?$/,uYe=/^(u?int)(8|16|24|32|40|48|56|64|72|80|88|96|104|112|120|128|136|144|152|160|168|176|184|192|200|208|216|224|232|240|248|256)?$/;function SJ(t){const{domain:n,message:e,primaryType:i,types:r}=t,s=(a,o)=>{for(const c of a){const{name:l,type:u}=c,d=o[l],h=u.match(uYe);if(h&&("number"==typeof d||"bigint"==typeof d)){const[D,V,we]=h;(0,Qn.eC)(d,{signed:"int"===V,size:parseInt(we)/8})}if("address"===u&&"string"==typeof d&&!(0,Q8.U)(d))throw new cYe.b({address:d});const y=u.match(lYe);if(y){const[D,V]=y;if(V&&(0,Vv.d)(d)!==parseInt(V))throw new bs.KY({expectedSize:parseInt(V),givenSize:(0,Vv.d)(d)})}const I=r[u];I&&s(I,d)}};r.EIP712Domain&&n&&s(r.EIP712Domain,n),"EIP712Domain"!==i&&s(r[i],e)}function RE({domain:t}){return["string"==typeof t?.name&&{name:"name",type:"string"},t?.version&&{name:"version",type:"string"},"number"==typeof t?.chainId&&{name:"chainId",type:"uint256"},t?.verifyingContract&&{name:"verifyingContract",type:"address"},t?.salt&&{name:"salt",type:"bytes32"}].filter(Boolean)}function dYe(t){const{domain:n={},message:e,primaryType:i}=t,r={EIP712Domain:RE({domain:n}),...t.types};SJ({domain:n,message:e,primaryType:i,types:r});const s=["0x1901"];return n&&s.push(function fYe({domain:t,types:n}){return EJ({data:t,primaryType:"EIP712Domain",types:n})}({domain:n,types:r})),"EIP712Domain"!==i&&s.push(EJ({data:e,primaryType:i,types:r})),(0,r2.w)((0,Ec.zo)(s))}function EJ({data:t,primaryType:n,types:e}){const i=AJ({data:t,primaryType:n,types:e});return(0,r2.w)(i)}function AJ({data:t,primaryType:n,types:e}){const i=[{type:"bytes32"}],r=[hYe({primaryType:n,types:e})];for(const s of e[n]){const[a,o]=DJ({types:e,name:s.name,type:s.type,value:t[s.name]});i.push(a),r.push(o)}return(0,bh.E)(i,r)}function hYe({primaryType:t,types:n}){const e=(0,Qn.NC)(function pYe({primaryType:t,types:n}){let e="";const i=IJ({primaryType:t,types:n});i.delete(t);const r=[t,...Array.from(i).sort()];for(const s of r)e+=`${s}(${n[s].map(({name:a,type:o})=>`${o} ${a}`).join(",")})`;return e}({primaryType:t,types:n}));return(0,r2.w)(e)}function IJ({primaryType:t,types:n},e=new Set){const r=t.match(/^\w*/u)?.[0];if(e.has(r)||void 0===n[r])return e;e.add(r);for(const s of n[r])IJ({primaryType:s.type,types:n},e);return e}function DJ({types:t,name:n,type:e,value:i}){if(void 0!==t[e])return[{type:"bytes32"},(0,r2.w)(AJ({data:i,primaryType:e,types:t}))];if("bytes"===e)return i="0x"+(i.length%2?"0":"")+i.slice(2),[{type:"bytes32"},(0,r2.w)(i)];if("string"===e)return[{type:"bytes32"},(0,r2.w)((0,Qn.NC)(i))];if(e.lastIndexOf("]")===e.length-1){const r=e.slice(0,e.lastIndexOf("[")),s=i.map(a=>DJ({name:n,type:r,types:t,value:a}));return[{type:"bytes32"},(0,r2.w)((0,bh.E)(s.map(([a])=>a),s.map(([,a])=>a)))]}return[{type:e},i]}function LE(){return(LE=(0,Ge.Z)(function*(t,n){const{address:e,signature:i,message:r,primaryType:s,types:a,domain:o,...c}=n;return kJ(t,{address:e,hash:dYe({message:r,primaryType:s,types:a,domain:o}),signature:i,...c})})).apply(this,arguments)}const PE=new Map,NJ=new Map;let gYe=0;function K3(t,n,e){const i=++gYe,r=()=>PE.get(t)||[],a=()=>{const u=NJ.get(t);1===r().length&&u&&u(),(()=>{const u=r();PE.set(t,u.filter(d=>d.id!==i))})()},o=r();if(PE.set(t,[...o,{id:i,fns:n}]),o&&o.length>0)return a;const c={};for(const u in n)c[u]=(...d)=>{const h=r();if(0!==h.length)for(const y of h)y.fns[u]?.(...d)};const l=e(c);return"function"==typeof l&&NJ.set(t,l),a}function zE(t){return OE.apply(this,arguments)}function OE(){return(OE=(0,Ge.Z)(function*(t){return new Promise(n=>setTimeout(n,t))})).apply(this,arguments)}function Wv(t,{delay:n=100,retryCount:e=2,shouldRetry:i=(()=>!0)}={}){return new Promise((r,s)=>{const a=function(){var o=(0,Ge.Z)(function*({count:c=0}={}){const l=function(){var u=(0,Ge.Z)(function*({error:d}){const h="function"==typeof n?n({count:c,error:d}):n;h&&(yield zE(h)),a({count:c+1})});return function(h){return u.apply(this,arguments)}}();try{const u=yield t();r(u)}catch(u){if(c<e&&(yield i({count:c,error:u})))return l({error:u});s(u)}});return function(){return o.apply(this,arguments)}}();a()})}var a2=$(38);function Th(t,{emitOnBegin:n,initialWaitTime:e,interval:i}){let r=!0;const s=()=>r=!1;return function(){var o=(0,Ge.Z)(function*(){let c;n&&(c=yield t({unpoll:s}));const l=(yield e?.(c))??i;yield zE(l);const u=function(){var d=(0,Ge.Z)(function*(){r&&(yield t({unpoll:s}),yield zE(i),u())});return function(){return d.apply(this,arguments)}}();u()});return function(){return o.apply(this,arguments)}}()(),s}function RJ(t,{emitOnBegin:n=!1,emitMissed:e=!1,onBlockNumber:i,onError:r,poll:s,pollingInterval:a=t.pollingInterval}){let c;return(typeof s<"u"?s:"webSocket"!==t.transport.type)?K3((0,a2.P)(["watchBlockNumber",t.uid,n,e,a]),{onBlockNumber:i,onError:r},h=>Th((0,Ge.Z)(function*(){try{const y=yield ri(t,xh,"getBlockNumber")({cacheTime:0});if(c){if(y===c)return;if(y-c>1&&e)for(let I=c+1n;I<y;I++)h.onBlockNumber(I,c),c=I}(!c||y>c)&&(h.onBlockNumber(y,c),c=y)}catch(y){h.onError?.(y)}}),{emitOnBegin:n,interval:a})):K3((0,a2.P)(["watchBlockNumber",t.uid,n,e]),{onBlockNumber:i,onError:r},h=>{let y=!0,I=()=>y=!1;return(0,Ge.Z)(function*(){try{const{unsubscribe:D}=yield t.transport.subscribe({params:["newHeads"],onData(V){if(!y)return;const we=(0,$2.y_)(V.result?.number);h.onBlockNumber(we,c),c=we},onError(V){h.onError?.(V)}});I=D,y||I()}catch(D){r?.(D)}})(),()=>I()})}function LJ(t,n){return HE.apply(this,arguments)}function HE(){return(HE=(0,Ge.Z)(function*(t,{confirmations:n=1,hash:e,onReplaced:i,pollingInterval:r=t.pollingInterval,retryCount:s=6,retryDelay:a=(({count:c})=>200*~~(1<<c)),timeout:o}){const c=(0,a2.P)(["waitForTransactionReceipt",t.uid,e]);let l,u,d,h=!1;return new Promise((y,I)=>{o&&setTimeout(()=>I(new W3.mc({hash:e})),o);const D=K3(c,{onReplaced:i,resolve:y,reject:I},V=>{const we=ri(t,RJ,"watchBlockNumber")({emitMissed:!0,emitOnBegin:!0,poll:!0,pollingInterval:r,onBlockNumber:Ce=>(0,Ge.Z)(function*(){if(h)return;let Ve=Ce;const Fe=qe=>{we(),qe(),D()};try{if(d){if(n>1&&(!d.blockNumber||Ve-d.blockNumber+1n<n))return;return void Fe(()=>V.resolve(d))}if(l||(h=!0,yield Wv((0,Ge.Z)(function*(){l=yield ri(t,Bv,"getTransaction")({hash:e}),l.blockNumber&&(Ve=l.blockNumber)}),{delay:a,retryCount:s}),h=!1),d=yield ri(t,xE,"getTransactionReceipt")({hash:e}),n>1&&(!d.blockNumber||Ve-d.blockNumber+1n<n))return;Fe(()=>V.resolve(d))}catch(qe){if(qe instanceof W3.Bh||qe instanceof W3.Yb){if(!l)return void(h=!1);try{u=l,h=!0;const nt=yield Wv(()=>ri(t,q3,"getBlock")({blockNumber:Ve,includeTransactions:!0}),{delay:a,retryCount:s,shouldRetry:({error:Et})=>Et instanceof tJ});h=!1;const dt=nt.transactions.find(({from:Et,nonce:Bt})=>Et===u.from&&Bt===u.nonce);if(!dt||(d=yield ri(t,xE,"getTransactionReceipt")({hash:dt.hash}),n>1&&(!d.blockNumber||Ve-d.blockNumber+1n<n)))return;let mt="replaced";dt.to===u.to&&dt.value===u.value?mt="repriced":dt.from===dt.to&&0n===dt.value&&(mt="cancelled"),Fe(()=>{V.onReplaced?.({reason:mt,replacedTransaction:u,transaction:dt,transactionReceipt:d}),V.resolve(d)})}catch(nt){Fe(()=>V.reject(nt))}}else Fe(()=>V.reject(qe))}})()})})})})).apply(this,arguments)}function PJ(t,n){return VE.apply(this,arguments)}function VE(){return(VE=(0,Ge.Z)(function*(t,{serializedTransaction:n}){return t.request({method:"eth_sendRawTransaction",params:[n]},{retryCount:0})})).apply(this,arguments)}function wYe(t){return{call:n=>(0,yh.RE)(t,n),createBlockFilter:()=>function sZe(t){return zS.apply(this,arguments)}(t),createContractEventFilter:n=>ZQ(t,n),createEventFilter:n=>YQ(t,n),createPendingTransactionFilter:()=>KQ(t),estimateContractGas:n=>function AZe(t,n){return rE.apply(this,arguments)}(t,n),estimateGas:n=>Ch(t,n),getBalance:n=>mJ(t,n),getBlobBaseFee:()=>function IZe(t){return aE.apply(this,arguments)}(t),getBlock:n=>q3(t,n),getBlockNumber:n=>xh(t,n),getBlockTransactionCount:n=>function PZe(t){return lE.apply(this,arguments)}(t,n),getBytecode:n=>function zZe(t,n){return uE.apply(this,arguments)}(t,n),getChainId:()=>JS(t),getContractEvents:n=>_J(t,n),getEnsAddress:n=>function WGe(t,n){return xS.apply(this,arguments)}(t,n),getEnsAvatar:n=>BQ(t,n),getEnsName:n=>UQ(t,n),getEnsResolver:n=>function rZe(t,n){return PS.apply(this,arguments)}(t,n),getEnsText:n=>FQ(t,n),getFeeHistory:n=>function FZe(t,n){return gE.apply(this,arguments)}(t,n),estimateFeesPerGas:n=>aJ(t,n),getFilterChanges:n=>Fv(t,n),getFilterLogs:n=>function BZe(t,n){return yE.apply(this,arguments)}(t,n),getGasPrice:()=>$S(t),getLogs:n=>hE(t,n),getProof:n=>function jZe(t,n){return _E.apply(this,arguments)}(t,n),estimateMaxPriorityFeePerGas:n=>function fZe(t,n){return WS.apply(this,arguments)}(t,n),getStorageAt:n=>function WZe(t,n){return bE.apply(this,arguments)}(t,n),getTransaction:n=>Bv(t,n),getTransactionConfirmations:n=>function qZe(t,n){return CE.apply(this,arguments)}(t,n),getTransactionCount:n=>oJ(t,n),getTransactionReceipt:n=>xE(t,n),multicall:n=>bJ(t,n),prepareTransactionRequest:n=>tE(t,n),readContract:n=>Al(t,n),sendRawTransaction:n=>PJ(t,n),simulateContract:n=>wJ(t,n),verifyMessage:n=>function oYe(t,n){return NE.apply(this,arguments)}(t,n),verifyTypedData:n=>function mYe(t,n){return LE.apply(this,arguments)}(t,n),uninstallFilter:n=>Uv(t,n),waitForTransactionReceipt:n=>LJ(t,n),watchBlocks:n=>function vYe(t,{blockTag:n="latest",emitMissed:e=!1,emitOnBegin:i=!1,onBlock:r,onError:s,includeTransactions:a,poll:o,pollingInterval:c=t.pollingInterval}){const u=a??!1;let d;return(typeof o<"u"?o:"webSocket"!==t.transport.type)?K3((0,a2.P)(["watchBlocks",t.uid,n,e,i,u,c]),{onBlock:r,onError:s},D=>Th((0,Ge.Z)(function*(){try{const V=yield ri(t,q3,"getBlock")({blockTag:n,includeTransactions:u});if(V.number&&d?.number){if(V.number===d.number)return;if(V.number-d.number>1&&e)for(let we=d?.number+1n;we<V.number;we++){const Ce=yield ri(t,q3,"getBlock")({blockNumber:we,includeTransactions:u});D.onBlock(Ce,d),d=Ce}}(!d?.number||"pending"===n&&!V?.number||V.number&&V.number>d.number)&&(D.onBlock(V,d),d=V)}catch(V){D.onError?.(V)}}),{emitOnBegin:i,interval:c})):(()=>{let I=!0,D=()=>I=!1;return(0,Ge.Z)(function*(){try{const{unsubscribe:V}=yield t.transport.subscribe({params:["newHeads"],onData(we){if(!I)return;const Ve=(t.chain?.formatters?.block?.format||rJ)(we.result);r(Ve,d),d=Ve},onError(we){s?.(we)}});D=V,I||D()}catch(V){s?.(V)}})(),()=>D()})()}(t,n),watchBlockNumber:n=>RJ(t,n),watchContractEvent:n=>function yYe(t,n){const{abi:e,address:i,args:r,batch:s=!0,eventName:a,fromBlock:o,onError:c,onLogs:l,poll:u,pollingInterval:d=t.pollingInterval,strict:h}=n;return(typeof u<"u"?u:"webSocket"!==t.transport.type||"number"==typeof o)?(()=>{const V=h??!1;return K3((0,a2.P)(["watchContractEvent",i,r,s,t.uid,a,d,V,o]),{onLogs:l,onError:c},Ce=>{let Ve;void 0!==o&&(Ve=o-1n);let Fe,qe=!1;const nt=Th((0,Ge.Z)(function*(){if(qe)try{let dt;if(Fe)dt=yield ri(t,Fv,"getFilterChanges")({filter:Fe});else{const mt=yield ri(t,xh,"getBlockNumber")({});dt=Ve&&Ve!==mt?yield ri(t,_J,"getContractEvents")({abi:e,address:i,args:r,eventName:a,fromBlock:Ve+1n,toBlock:mt,strict:V}):[],Ve=mt}if(0===dt.length)return;if(s)Ce.onLogs(dt);else for(const mt of dt)Ce.onLogs([mt])}catch(dt){Fe&&dt instanceof $4&&(qe=!1),Ce.onError?.(dt)}else{try{Fe=yield ri(t,ZQ,"createContractEventFilter")({abi:e,address:i,args:r,eventName:a,strict:V,fromBlock:o})}catch{}qe=!0}}),{emitOnBegin:!0,interval:d});return(0,Ge.Z)(function*(){Fe&&(yield ri(t,Uv,"uninstallFilter")({filter:Fe})),nt()})})})():(()=>{const we=(0,a2.P)(["watchContractEvent",i,r,s,t.uid,a,d,h??!1]);let Ce=!0,Ve=()=>Ce=!1;return K3(we,{onLogs:l,onError:c},Fe=>((0,Ge.Z)(function*(){try{const qe=a?wh({abi:e,eventName:a,args:r}):[],{unsubscribe:nt}=yield t.transport.subscribe({params:["logs",{address:i,topics:qe}],onData(dt){if(!Ce)return;const mt=dt.result;try{const{eventName:Et,args:Bt}=dE({abi:e,data:mt.data,topics:mt.topics,strict:h}),tn=Y3(mt,{args:Bt,eventName:Et});Fe.onLogs([tn])}catch(Et){let Bt,tn;if(Et instanceof bs.SM||Et instanceof bs.Gy){if(h)return;Bt=Et.abiItem.name,tn=Et.abiItem.inputs?.some(En=>!("name"in En&&En.name))}const on=Y3(mt,{args:tn?[]:{},eventName:Bt});Fe.onLogs([on])}},onError(dt){Fe.onError?.(dt)}});Ve=nt,Ce||Ve()}catch(qe){c?.(qe)}})(),()=>Ve()))})()}(t,n),watchEvent:n=>function _Ye(t,{address:n,args:e,batch:i=!0,event:r,events:s,fromBlock:a,onError:o,onLogs:c,poll:l,pollingInterval:u=t.pollingInterval,strict:d}){const y=d??!1;return(typeof l<"u"?l:"webSocket"!==t.transport.type||"bigint"==typeof a)?K3((0,a2.P)(["watchEvent",n,e,i,t.uid,r,u,a]),{onLogs:c,onError:o},we=>{let Ce;void 0!==a&&(Ce=a-1n);let Ve,Fe=!1;const qe=Th((0,Ge.Z)(function*(){if(Fe)try{let nt;if(Ve)nt=yield ri(t,Fv,"getFilterChanges")({filter:Ve});else{const dt=yield ri(t,xh,"getBlockNumber")({});nt=Ce&&Ce!==dt?yield ri(t,hE,"getLogs")({address:n,args:e,event:r,events:s,fromBlock:Ce+1n,toBlock:dt}):[],Ce=dt}if(0===nt.length)return;if(i)we.onLogs(nt);else for(const dt of nt)we.onLogs([dt])}catch(nt){Ve&&nt instanceof $4&&(Fe=!1),we.onError?.(nt)}else{try{Ve=yield ri(t,YQ,"createEventFilter")({address:n,args:e,event:r,events:s,strict:y,fromBlock:a})}catch{}Fe=!0}}),{emitOnBegin:!0,interval:u});return(0,Ge.Z)(function*(){Ve&&(yield ri(t,Uv,"uninstallFilter")({filter:Ve})),qe()})}):(()=>{let V=!0,we=()=>V=!1;return(0,Ge.Z)(function*(){try{const Ce=s??(r?[r]:void 0);let Ve=[];Ce&&(Ve=[Ce.flatMap(qe=>wh({abi:[qe],eventName:qe.name,args:e}))],r&&(Ve=Ve[0]));const{unsubscribe:Fe}=yield t.transport.subscribe({params:["logs",{address:n,topics:Ve}],onData(qe){if(!V)return;const nt=qe.result;try{const{eventName:dt,args:mt}=dE({abi:Ce??[],data:nt.data,topics:nt.topics,strict:y}),Et=Y3(nt,{args:mt,eventName:dt});c([Et])}catch(dt){let mt,Et;if(dt instanceof bs.SM||dt instanceof bs.Gy){if(d)return;mt=dt.abiItem.name,Et=dt.abiItem.inputs?.some(tn=>!("name"in tn&&tn.name))}const Bt=Y3(nt,{args:Et?[]:{},eventName:mt});c([Bt])}},onError(qe){o?.(qe)}});we=Fe,V||we()}catch(Ce){o?.(Ce)}})(),()=>we()})()}(t,n),watchPendingTransactions:n=>function bYe(t,{batch:n=!0,onError:e,onTransactions:i,poll:r,pollingInterval:s=t.pollingInterval}){return(typeof r<"u"?r:"webSocket"!==t.transport.type)?K3((0,a2.P)(["watchPendingTransactions",t.uid,n,s]),{onTransactions:i,onError:e},u=>{let d;const h=Th((0,Ge.Z)(function*(){try{if(!d)try{return void(d=yield ri(t,KQ,"createPendingTransactionFilter")({}))}catch(I){throw h(),I}const y=yield ri(t,Fv,"getFilterChanges")({filter:d});if(0===y.length)return;if(n)u.onTransactions(y);else for(const I of y)u.onTransactions([I])}catch(y){u.onError?.(y)}}),{emitOnBegin:!0,interval:s});return(0,Ge.Z)(function*(){d&&(yield ri(t,Uv,"uninstallFilter")({filter:d})),h()})}):(()=>{let l=!0,u=()=>l=!1;return(0,Ge.Z)(function*(){try{const{unsubscribe:d}=yield t.transport.subscribe({params:["newPendingTransactions"],onData(h){l&&i([h.result])},onError(h){e?.(h)}});u=d,l||u()}catch(d){e?.(d)}})(),()=>u()})()}(t,n)}}function zJ(t){const{key:n="public",name:e="Public Client"}=t;return bS({...t,key:n,name:e,type:"publicClient"}).extend(wYe)}class OJ extends Bs.G{constructor(){super("No URL was provided to the Transport. Please provide a valid RPC URL to the Transport.",{docsPath:"/docs/clients/intro"})}}var HJ=$(7447);function FE(t,{errorInstance:n=new Error("timed out"),timeout:e,signal:i}){return new Promise((r,s)=>{(0,Ge.Z)(function*(){let a;try{const o=new AbortController;e>0&&(a=setTimeout(()=>{i?o.abort():s(n)},e)),r(yield t({signal:o?.signal||null}))}catch(o){"AbortError"===o.name&&s(n),s(o)}finally{clearTimeout(a)}})()})}function CYe(){return{current:0,take(){return this.current++},reset(){this.current=0}}}const BE=CYe();function xYe(t,n={}){return function(){var e=(0,Ge.Z)(function*(i,r={}){const{retryDelay:s=150,retryCount:a=3}={...n,...r};return Wv((0,Ge.Z)(function*(){try{return yield t(i)}catch(o){const c=o;switch(c.code){case sh.code:throw new sh(c);case ah.code:throw new ah(c);case oh.code:throw new oh(c);case ch.code:throw new ch(c);case U4.code:throw new U4(c);case $4.code:throw new $4(c);case lh.code:throw new lh(c);case j3.code:throw new j3(c);case uh.code:throw new uh(c);case dh.code:throw new dh(c);case Cd.code:throw new Cd(c);case fh.code:throw new fh(c);case jr.code:throw new jr(c);case hh.code:throw new hh(c);case ph.code:throw new ph(c);case mh.code:throw new mh(c);case gh.code:throw new gh(c);case S1.code:throw new S1(c);case 5e3:throw new jr(c);default:throw o instanceof Bs.G?o:new $Ge(c)}}}),{delay:({count:o,error:c})=>{if(c&&c instanceof s2.Gg){const l=c?.headers?.get("Retry-After");if(l?.match(/\d/))return 1e3*parseInt(l)}return~~(1<<o)*s},retryCount:a,shouldRetry:({error:o})=>function TYe(t){return"code"in t&&"number"==typeof t.code?-1===t.code||t.code===Cd.code||t.code===U4.code:!(t instanceof s2.Gg&&t.status)||403===t.status||408===t.status||413===t.status||429===t.status||500===t.status||502===t.status||503===t.status||504===t.status}(o)})});return function(i){return e.apply(this,arguments)}}()}function UE({key:t,name:n,request:e,retryCount:i=3,retryDelay:r=150,timeout:s,type:a},o){return{config:{key:t,name:n,request:e,retryCount:i,retryDelay:r,timeout:s,type:a},request:xYe(e,{retryCount:i,retryDelay:r}),value:o}}function $E(t,n={}){const{batch:e,fetchOptions:i,key:r="http",name:s="HTTP JSON-RPC",onFetchRequest:a,onFetchResponse:o,retryDelay:c}=n;return({chain:l,retryCount:u,timeout:d})=>{const{batchSize:h=1e3,wait:y=0}="object"==typeof e?e:{},I=n.retryCount??u,D=d??n.timeout??1e4,V=t||l?.rpcUrls.default.http[0];if(!V)throw new OJ;const we=function VJ(t,n={}){return{request:e=>(0,Ge.Z)(function*(){const{body:i,fetchOptions:r={},onRequest:s=n.onRequest,onResponse:a=n.onResponse,timeout:o=n.timeout??1e4}=e,{headers:c,method:l,signal:u}={...n.fetchOptions,...r};try{const d=yield FE(function(){var y=(0,Ge.Z)(function*({signal:I}){const D={...r,body:Array.isArray(i)?(0,a2.P)(i.map(Ce=>({jsonrpc:"2.0",id:Ce.id??BE.take(),...Ce}))):(0,a2.P)({jsonrpc:"2.0",id:i.id??BE.take(),...i}),headers:{...c,"Content-Type":"application/json"},method:l||"POST",signal:u||(o>0?I:null)},V=new Request(t,D);return s&&(yield s(V)),yield fetch(t,D)});return function(I){return y.apply(this,arguments)}}(),{errorInstance:new s2.W5({body:i,url:t}),timeout:o,signal:!0});let h;if(a&&(yield a(d)),h=d.headers.get("Content-Type")?.startsWith("application/json")?yield d.json():yield d.text(),!d.ok)throw new s2.Gg({body:i,details:(0,a2.P)(h.error)||d.statusText,headers:d.headers,status:d.status,url:t});return h}catch(d){throw d instanceof s2.Gg||d instanceof s2.W5?d:new s2.Gg({body:i,details:d.message,url:t})}})()}}(V,{fetchOptions:i,onRequest:a,onResponse:o,timeout:D});return UE({key:r,name:s,request:({method:Ce,params:Ve})=>(0,Ge.Z)(function*(){const Fe={method:Ce,params:Ve},{schedule:qe}=(0,HJ.S)({id:`${t}`,wait:y,shouldSplitBatch:Et=>Et.length>h,fn:Et=>we.request({body:Et}),sort:(Et,Bt)=>Et.id-Bt.id}),nt=function(){var Et=(0,Ge.Z)(function*(Bt){return e?qe(Bt):[yield we.request({body:Bt})]});return function(tn){return Et.apply(this,arguments)}}(),[{error:dt,result:mt}]=yield nt(Fe);if(dt)throw new s2.bs({body:Fe,error:dt,url:V});return mt})(),retryCount:I,retryDelay:c,timeout:D,type:"http"},{fetchOptions:i,url:V})}}const jE=new Map;function WE(){return WE=(0,Ge.Z)(function*(t){const{getSocket:n,reconnect:e=!0,url:i}=t,{attempts:r=5,delay:s=2e3}="object"==typeof e?e:{};let a=jE.get(i);if(a)return a;let o=0;const{schedule:c}=(0,HJ.S)({id:i,fn:(d=(0,Ge.Z)(function*(){const h=new Map,y=new Map;let I,D;function V(){return we.apply(this,arguments)}function we(){return(we=(0,Ge.Z)(function*(){return n({onError(Ce){I=Ce;for(const Ve of h.values())Ve.onError?.(I);for(const Ve of y.values())Ve.onError?.(I);h.clear(),y.clear(),e&&o<r&&setTimeout((0,Ge.Z)(function*(){o++,D=yield V().catch(console.error)}),s)},onOpen(){I=void 0,o=0},onResponse(Ce){const Ve="eth_subscription"===Ce.method,Fe=Ve?Ce.params.subscription:Ce.id,qe=Ve?y:h,nt=qe.get(Fe);nt&&nt.onResponse(Ce),Ve||qe.delete(Fe)}})})).apply(this,arguments)}return D=yield V(),I=void 0,a={close(){D.close(),jE.delete(i)},socket:D,request({body:Ce,onError:Ve,onResponse:Fe}){I&&Ve&&Ve(I);const qe=Ce.id??BE.take(),nt=dt=>{"number"==typeof dt.id&&qe!==dt.id||("eth_subscribe"===Ce.method&&"string"==typeof dt.result&&y.set(dt.result,{onResponse:nt,onError:Ve}),"eth_unsubscribe"===Ce.method&&y.delete(Ce.params?.[0]),Fe(dt))};h.set(qe,{onResponse:nt,onError:Ve});try{D.request({body:{jsonrpc:"2.0",id:qe,...Ce}})}catch(dt){Ve?.(dt)}},requestAsync({body:Ce,timeout:Ve=1e4}){return FE(()=>new Promise((Fe,qe)=>this.request({body:Ce,onError:qe,onResponse:Fe})),{errorInstance:new s2.W5({body:Ce,url:i}),timeout:Ve})},requests:h,subscriptions:y,url:i},jE.set(i,a),[a]}),function(){return d.apply(this,arguments)})}),[l,[u]]=yield c();var d;return u}),WE.apply(this,arguments)}function qv(t){return qE.apply(this,arguments)}function qE(){return qE=(0,Ge.Z)(function*(t,n={}){const{reconnect:e}=n;return function MYe(t){return WE.apply(this,arguments)}({getSocket:({onError:i,onOpen:r,onResponse:s})=>(0,Ge.Z)(function*(){const a=yield $.e(722).then($.bind($,722)).then(d=>d.WebSocket),o=new a(t);function c(){o.removeEventListener("close",c),o.removeEventListener("message",l),o.removeEventListener("error",i),o.removeEventListener("open",r)}function l({data:d}){s(JSON.parse(d))}o.addEventListener("close",c),o.addEventListener("message",l),o.addEventListener("error",i),o.addEventListener("open",r),o.readyState===a.CONNECTING&&(yield new Promise((d,h)=>{o&&(o.onopen=d,o.onerror=h)}));const{close:u}=o;return Object.assign(o,{close(){u.bind(o)(),c()},request({body:d}){if(o.readyState===o.CLOSED||o.readyState===o.CLOSING)throw new s2.c9({body:d,url:o.url,details:"Socket is closed."});return o.send(JSON.stringify(d))}})})(),reconnect:e,url:t})}),qE.apply(this,arguments)}function ZE(){return(ZE=(0,Ge.Z)(function*(t){const n=yield qv(t);return Object.assign(n.socket,{requests:n.requests,subscriptions:n.subscriptions})})).apply(this,arguments)}let Mh=(()=>{class t{constructor(){}httpClient(e){return zJ({chain:e,transport:this.httpTransport(e)})}wssClient(e){return zJ({chain:e,transport:this.wssTransport(e)})}httpTransport(e){let i=null,r=null;switch(e.id){case an.id:i="https://eth-mainnet.g.alchemy.com/v2",r=Jr_ALCHEMY_MAINNET_KEY;break;case bi.id:i="https://arb-mainnet.g.alchemy.com/v2",r="bJQpStjckrDSor32ZeGU4g3CYOgmcPHk";break;case fi.id:i="https://eth-sepolia.g.alchemy.com/v2",r="rpDrPK9AKpJKYDecx9XCnhqnDwfTfQfj";break;default:i="https://eth-mainnet.g.alchemy.com/v2",r=Jr_ALCHEMY_MAINNET_KEY}return $E(i,{fetchOptions:{headers:{Authorization:`Bearer ${r}`}}})}wssTransport(e){let i=null;switch(e.id){case an.id:i=`wss://eth-mainnet.g.alchemy.com/v2/${Jr_ALCHEMY_MAINNET_KEY}`;break;case bi.id:i="wss://arb-mainnet.g.alchemy.com/v2/bJQpStjckrDSor32ZeGU4g3CYOgmcPHk";break;case fi.id:i="wss://eth-sepolia.g.alchemy.com/v2/rpDrPK9AKpJKYDecx9XCnhqnDwfTfQfj";break;default:i=`wss://eth-mainnet.g.alchemy.com/v2/${Jr_ALCHEMY_MAINNET_KEY}`}return function AYe(t,n={}){const{key:e="webSocket",name:i="WebSocket JSON-RPC",reconnect:r,retryDelay:s}=n;return({chain:a,retryCount:o,timeout:c})=>{const l=n.retryCount??o,u=c??n.timeout??1e4,d=t||a?.rpcUrls.default.webSocket?.[0];if(!d)throw new OJ;return UE({key:e,name:i,request:({method:h,params:y})=>(0,Ge.Z)(function*(){const I={method:h,params:y},D=yield qv(d,{reconnect:r}),{error:V,result:we}=yield D.requestAsync({body:I,timeout:u});if(V)throw new s2.bs({body:I,error:V,url:d});return we})(),retryCount:l,retryDelay:s,timeout:u,type:"webSocket"},{getSocket:()=>function EYe(t){return ZE.apply(this,arguments)}(d),getRpcClient:()=>qv(d),subscribe:({params:h,onData:y,onError:I})=>(0,Ge.Z)(function*(){const D=yield qv(d),{result:V}=yield new Promise((we,Ce)=>D.request({body:{method:"eth_subscribe",params:h},onResponse(Ve){if(Ve.error)return Ce(Ve.error),void I?.(Ve.error);"number"!=typeof Ve.id?"eth_subscription"===Ve.method&&y(Ve.params):we(Ve)}}));return{subscriptionId:V,unsubscribe:()=>(0,Ge.Z)(function*(){return new Promise(we=>D.request({body:{method:"eth_unsubscribe",params:[V]},onResponse:we}))})()}})()})}}(i)}static#e=this.\u0275fac=function(i){return new(i||t)};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})(),br=(()=>{class t{constructor(e){this.viem=e}processWeb3Number(e){return new Oe.Z(e).integerValue().toFixed()}sortByProp(e,i,r){return 0===e.length?e:e.sort(!0===r?e[0][i]instanceof Function?(s,a)=>s[i]().gt(a[i]())?1:s[i]().lt(a[i]())?-1:0:e[0][i]instanceof Oe.Z?(s,a)=>s[i].gt(a[i])?1:s[i].lt(a[i])?-1:0:(s,a)=>s[i]>a[i]?1:s[i]<a[i]?-1:0:e[0][i]instanceof Function?(s,a)=>a[i]().gt(s[i]())?1:a[i]().lt(s[i]())?-1:0:e[0][i]instanceof Oe.Z?(s,a)=>a[i].gt(s[i])?1:a[i].lt(s[i])?-1:0:(s,a)=>a[i]>s[i]?1:a[i]<s[i]?-1:0)}multicall(e,i,r){var s=this;return(0,Ge.Z)(function*(){return s.viem.httpClient(i).multicall({contracts:e,batchSize:0,...r&&{blockNumber:r}})})()}readContract(e,i){var r=this;return(0,Ge.Z)(function*(){return r.viem.httpClient(i).readContract(e)})()}sort(e,i,r){return e.slice().sort((s,a)=>{const o=this.resolveNestedProperty(s,i),c=this.resolveNestedProperty(a,i);return!0===r?o instanceof Oe.Z&&c instanceof Oe.Z?o.gt(c)?1:o.lt(c)?-1:0:o>c?1:o<c?-1:0:o instanceof Oe.Z&&c instanceof Oe.Z?c.gt(o)?1:c.lt(o)?-1:0:c>o?1:c<o?-1:0})}resolveNestedProperty(e,i){let r=e;for(const s of i.split(".")){const[a,o]=s.split("("),c=o?o.slice(0,-1):void 0;r=r[a]instanceof Function?c?r[a](this.coerce(c)):r[a]():r[a]}return r}coerce(e){return"true"===e||"false"!==e&&(isNaN(parseFloat(e))?/^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/.test(e)?new Oe.Z(e):e:parseFloat(e))}static#e=this.\u0275fac=function(i){return new(i||t)(gt(Mh))};static#t=this.\u0275prov=Pt({token:t,factory:t.\u0275fac,providedIn:"root"})}return t})();function YE(t,n){if(t===n)return!0;if(t&&n&&"object"==typeof t&&"object"==typeof n){if(t.constructor!==n.constructor)return!1;let e,i;if(Array.isArray(t)&&Array.isArray(n)){if(e=t.length,e!==n.length)return!1;for(i=e;0!=i--;)if(!YE(t[i],n[i]))return!1;return!0}if(t.valueOf!==Object.prototype.valueOf)return t.valueOf()===n.valueOf();if(t.toString!==Object.prototype.toString)return t.toString()===n.toString();const r=Object.keys(t);if(e=r.length,e!==Object.keys(n).length)return!1;for(i=e;0!=i--;)if(!Object.prototype.hasOwnProperty.call(n,r[i]))return!1;for(i=e;0!=i--;){const s=r[i];if(s&&!YE(t[s],n[s]))return!1}return!0}return t!=t&&n!=n}function FJ(t,n){const{onChange:e}=n;return t.subscribe(()=>function IYe(t){const e=t.state.connections.get(t.state.current),i=e?.accounts,r=i?.[0],s=t.chains.find(o=>o.id===e?.chainId),a=t.state.status;switch(a){case"connected":return{address:r,addresses:i,chain:s,chainId:e?.chainId,connector:e?.connector,isConnected:!0,isConnecting:!1,isDisconnected:!1,isReconnecting:!1,status:a};case"reconnecting":return{address:r,addresses:i,chain:s,chainId:e?.chainId,connector:e?.connector,isConnected:!!r,isConnecting:!1,isDisconnected:!1,isReconnecting:!0,status:a};case"connecting":return{address:r,addresses:i,chain:s,chainId:e?.chainId,connector:e?.connector,isConnected:!1,isConnecting:!0,isDisconnected:!1,isReconnecting:!1,status:a};case"disconnected":return{address:void 0,addresses:void 0,chain:void 0,chainId:void 0,connector:void 0,isConnected:!1,isConnecting:!1,isDisconnected:!0,isReconnecting:!1,status:a}}}(t),e,{equalityFn(i,r){const{connector:s,...a}=i,{connector:o,...c}=r;return YE(a,c)&&s?.id===o?.id&&s?.uid===o?.uid}})}function Ha(t,n,e){const i=t[n.name];if("function"==typeof i)return i;const r=t[e];return"function"==typeof r?r:s=>n(t,s)}function BJ(t,n){const{chainId:e,...i}=n;return Ha(t.getClient({chainId:e}),UQ,"getEnsName")(i)}const Gv="2.6.17";var Zv,$J,UJ=function(t,n,e,i){if("a"===e&&!i)throw new TypeError("Private accessor was defined without a getter");if("function"==typeof n?t!==n||!i:!n.has(t))throw new TypeError("Cannot read private member from an object whose class did not declare it");return"m"===e?i:"a"===e?i.call(t):i?i.value:n.get(t)};class Il extends Error{get docsBaseUrl(){return"https://wagmi.sh/core"}get version(){return`@wagmi/core@${Gv}`}constructor(n,e={}){super(),Zv.add(this),Object.defineProperty(this,"details",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),Object.defineProperty(this,"docsPath",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),Object.defineProperty(this,"metaMessages",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),Object.defineProperty(this,"shortMessage",{enumerable:!0,configurable:!0,writable:!0,value:void 0}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"WagmiCoreError"});const i=e.cause instanceof Il?e.cause.details:e.cause?.message?e.cause.message:e.details,r=e.cause instanceof Il&&e.cause.docsPath||e.docsPath;this.message=[n||"An error occurred.","",...e.metaMessages?[...e.metaMessages,""]:[],...r?[`Docs: ${this.docsBaseUrl}${r}.html${e.docsSlug?`#${e.docsSlug}`:""}`]:[],...i?[`Details: ${i}`]:[],`Version: ${this.version}`].join("\n"),e.cause&&(this.cause=e.cause),this.details=i,this.docsPath=r,this.metaMessages=e.metaMessages,this.shortMessage=n}walk(n){return UJ(this,Zv,"m",$J).call(this,this,n)}}Zv=new WeakSet,$J=function t(n,e){return e?.(n)?n:n.cause?UJ(this,Zv,"m",t).call(this,n.cause,e):n};class xd extends Il{constructor(){super("Chain not configured."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ChainNotConfiguredError"})}}class NYe extends Il{constructor(){super("Connector already connected."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ConnectorAlreadyConnectedError"})}}class RYe extends Il{constructor(){super("Connector not connected."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ConnectorNotConnectedError"})}}class LYe extends Il{constructor({address:n,connector:e}){super(`Account "${n}" not found for connector "${e.name}".`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ConnectorAccountNotFoundError"})}}class j4 extends Il{constructor(){super("Provider not found."),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"ProviderNotFoundError"})}}class PYe extends Il{constructor({connector:n}){super(`"${n.name}" does not support programmatic chain switching.`),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"SwitchChainNotSupportedError"})}}function jJ(t,n){return KE.apply(this,arguments)}function KE(){return(KE=(0,Ge.Z)(function*(t,n){const{chainId:e}=n,i=t.state.connections.get(n.connector?.uid??t.state.current);if(i){const s=i.connector;if(!s.switchChain)throw new PYe({connector:s});return yield s.switchChain({chainId:e})}const r=t.chains.find(s=>s.id===e);if(!r)throw new xd;return t.setState(s=>({...s,chainId:e})),r})).apply(this,arguments)}var o2=$(6284);function Td(t){return XE.apply(this,arguments)}function XE(){return(XE=(0,Ge.Z)(function*(t,n={}){let e;if(n.connector){const{connector:c}=n,[l,u]=yield Promise.all([c.getAccounts(),c.getChainId()]);e={accounts:l,chainId:u,connector:c}}else e=t.state.connections.get(t.state.current);if(!e)throw new RYe;const i=n.chainId??e.chainId,r=e.connector;if(r.getClient)return r.getClient({chainId:i});const s=(0,kl.T)(n.account??e.accounts[0]);s.address=(0,o2.K)(s.address);const a=t.chains.find(c=>c.id===i),o=yield e.connector.getProvider({chainId:i});if(n.account&&!e.accounts.includes(s.address))throw new LYe({address:s.address,connector:r});return bS({account:s,chain:a,name:"Connector Client",transport:c=>function zYe(t,n={}){const{key:e="custom",name:i="Custom Provider",retryDelay:r}=n;return({retryCount:s})=>UE({key:e,name:i,request:t.request.bind(t),retryCount:n.retryCount??s,retryDelay:r,type:"custom"})}(o)({...c,retryCount:0})})})).apply(this,arguments)}function WJ(t,n){return QE.apply(this,arguments)}function QE(){return(QE=(0,Ge.Z)(function*(t,n){const{chainId:e,connector:i,...r}=n;let s;return s=n.account?n.account:(yield Td(t,{account:n.account,chainId:e,connector:i})).account,Ha(t.getClient({chainId:e}),Ch,"estimateGas")({...r,account:s})})).apply(this,arguments)}class JE extends Bs.G{constructor({docsPath:n}={}){super(["Could not find an Account to execute with this Action.","Please provide an Account with the `account` argument on the Action, or by supplying an `account` to the WalletClient."].join("\n"),{docsPath:n,docsSlug:"account"}),Object.defineProperty(this,"name",{enumerable:!0,configurable:!0,writable:!0,value:"AccountNotFoundError"})}}var qJ=$(8722);function GJ(t,n){return eA.apply(this,arguments)}function eA(){return(eA=(0,Ge.Z)(function*(t,n){const{account:e=t.account,chain:i=t.chain,accessList:r,blobs:s,data:a,gas:o,gasPrice:c,maxFeePerBlobGas:l,maxFeePerGas:u,maxPriorityFeePerGas:d,nonce:h,to:y,value:I,...D}=n;if(!e)throw new JE({docsPath:"/docs/actions/wallet/sendTransaction"});const V=(0,kl.T)(e);try{let we;if((0,FS.F)(n),null!==i&&(we=yield ri(t,JS,"getChainId")({}),function OYe({chain:t,currentChainId:n}){if(!t)throw new qJ.Bk;if(n!==t.id)throw new qJ.Yl({chain:t,currentChainId:n})}({currentChainId:we,chain:i})),"local"===V.type){const qe=yield ri(t,tE,"prepareTransactionRequest")({account:V,accessList:r,blobs:s,chain:i,chainId:we,data:a,gas:o,gasPrice:c,maxFeePerBlobGas:l,maxFeePerGas:u,maxPriorityFeePerGas:d,nonce:h,parameters:[...pJ,"sidecars"],to:y,value:I,...D}),nt=i?.serializers?.transaction,dt=yield V.signTransaction(qe,{serializer:nt});return yield ri(t,PJ,"sendRawTransaction")({serializedTransaction:dt})}const Ce=t.chain?.formatters?.transactionRequest?.format,Fe=(Ce||eJ.tG)({...(0,JQ.K)(D,{format:Ce}),accessList:r,blobs:s,data:a,from:V.address,gas:o,gasPrice:c,maxFeePerBlobGas:l,maxFeePerGas:u,maxPriorityFeePerGas:d,nonce:h,to:y,value:I});return yield t.request({method:"eth_sendTransaction",params:[Fe]},{retryCount:0})}catch(we){throw function HYe(t,{docsPath:n,...e}){const i=(()=>{const r=(0,QQ.k)(t,e);return r instanceof XQ.cj?t:r})();return new W3.mk(i,{docsPath:n,...e})}(we,{...n,account:V,chain:n.chain||void 0})}})).apply(this,arguments)}function tA(){return(tA=(0,Ge.Z)(function*(t,n){const{account:e,chainId:i,connector:r,gas:s,...a}=n;let o;o="object"==typeof e&&"local"===e.type?t.getClient({chainId:i}):yield Td(t,{account:e,chainId:i,connector:r});const c=yield(0,Ge.Z)(function*(){if(null!==s)return void 0===s?Ha(o,Ch,"estimateGas")({...a,account:e,chain:i?{id:i}:null}):s})();return yield Ha(o,GJ,"sendTransaction")({...a,...e?{account:e}:{},gas:c,chain:i?{id:i}:null})})).apply(this,arguments)}function ZJ(t,n){return nA.apply(this,arguments)}function nA(){return(nA=(0,Ge.Z)(function*(t,n){const{chainId:e,timeout:i=0,...r}=n,s=t.getClient({chainId:e}),o=yield Ha(s,LJ,"waitForTransactionReceipt")({...r,timeout:i});if("reverted"===o.status){const l=yield Ha(s,Bv,"getTransaction")({hash:o.transactionHash}),d=yield Ha(s,yh.RE,"call")({...l,gasPrice:"eip1559"!==l.type?l.gasPrice:void 0,maxFeePerGas:"eip1559"===l.type?l.maxFeePerGas:void 0,maxPriorityFeePerGas:"eip1559"===l.type?l.maxPriorityFeePerGas:void 0}),h=d?(0,$2.rR)(`0x${d.substring(138)}`):"unknown reason";throw new Error(h)}return{...o,chainId:s.chain.id}})).apply(this,arguments)}function YJ(t,n){return iA.apply(this,arguments)}function iA(){return(iA=(0,Ge.Z)(function*(t,n){const{abi:e,chainId:i,connector:r,...s}=n;let a;a=n.account?n.account:(yield Td(t,{chainId:i,connector:r})).account;const o=t.getClient({chainId:i}),c=Ha(o,wJ,"simulateContract"),{result:l,request:u}=yield c({...s,abi:e,account:a});return{chainId:o.chain.id,result:l,request:{__mode:"prepared",...u,chainId:i}}})).apply(this,arguments)}function FYe(t,n){return rA.apply(this,arguments)}function rA(){return(rA=(0,Ge.Z)(function*(t,n){const{account:e=t.account,domain:i,message:r,primaryType:s}=n;if(!e)throw new JE({docsPath:"/docs/actions/wallet/signTypedData"});const a=(0,kl.T)(e),o={EIP712Domain:RE({domain:i}),...n.types};if(SJ({domain:i,message:r,primaryType:s,types:o}),"local"===a.type)return a.signTypedData({domain:i,message:r,primaryType:s,types:o});const c=(0,a2.P)({domain:i??{},message:r,primaryType:s,types:o},(l,u)=>(0,bd.v)(u)?u.toLowerCase():u);return t.request({method:"eth_signTypedData_v4",params:[a.address,c]},{retryCount:0})})).apply(this,arguments)}function sA(){return(sA=(0,Ge.Z)(function*(t,n){const{account:e,connector:i,...r}=n;let s;return s="object"==typeof e&&"local"===e.type?t.getClient():yield Td(t,{account:e,connector:i}),Ha(s,FYe,"signTypedData")({...r,...e?{account:e}:{}})})).apply(this,arguments)}var kh=$(4102),UYe=$(9744);function aA(t){return"number"==typeof t?t:"wei"===t?0:Math.abs(UYe.Bd[t])}function $Ye(t){return oA.apply(this,arguments)}function oA(){return(oA=(0,Ge.Z)(function*(t,n={}){const{chainId:e,formatUnits:i="gwei",...r}=n,s=t.getClient({chainId:e}),a=Ha(s,aJ,"estimateFeesPerGas"),{gasPrice:o,maxFeePerGas:c,maxPriorityFeePerGas:l}=yield a({...r,chain:s.chain}),u=aA(i);return{formatted:{gasPrice:o?(0,kh.b)(o,u):void 0,maxFeePerGas:c?(0,kh.b)(c,u):void 0,maxPriorityFeePerGas:l?(0,kh.b)(l,u):void 0},gasPrice:o,maxFeePerGas:c,maxPriorityFeePerGas:l}})).apply(this,arguments)}function jYe(t,n){return cA.apply(this,arguments)}function cA(){return(cA=(0,Ge.Z)(function*(t,n){const{abi:e,address:i,args:r,dataSuffix:s,functionName:a,...o}=n,c=(0,El.R)({abi:e,args:r,functionName:a});return ri(t,GJ,"sendTransaction")({data:`${c}${s?s.replace("0x",""):""}`,to:i,...o})})).apply(this,arguments)}function lA(){return(lA=(0,Ge.Z)(function*(t,n){const{account:e,chainId:i,connector:r,__mode:s,...a}=n;let o,c;if(o="object"==typeof e&&"local"===e.type?t.getClient({chainId:i}):yield Td(t,{account:e,chainId:i,connector:r}),"prepared"===s)c=a;else{const{request:d}=yield YJ(t,{...a,account:e,chainId:i});c=d}return yield Ha(o,jYe,"writeContract")({...c,...e?{account:e}:{},chain:i?{id:i}:null})})).apply(this,arguments)}function qYe(t,n){return JSON.parse(t,(e,i)=>{let r=i;return"bigint"===r?.__type&&(r=BigInt(r.value)),"Map"===r?.__type&&(r=new Map(r.value)),n?.(e,r)??r})}function KJ(t,n){return t.slice(0,n).join(".")||"."}function XJ(t,n){const{length:e}=t;for(let i=0;i<e;++i)if(t[i]===n)return i+1;return 0}function ZYe(t,n,e,i){return JSON.stringify(t,function GYe(t,n){const e="function"==typeof t,i="function"==typeof n,r=[],s=[];return function(o,c){if("object"==typeof c)if(r.length){const l=XJ(r,this);0===l?r[r.length]=this:(r.splice(l),s.splice(l)),s[s.length]=o;const u=XJ(r,c);if(0!==u)return i?n.call(this,o,c,KJ(s,u)):`[ref=${KJ(s,u)}]`}else r[0]=c,s[0]=o;return e?t.call(this,o,c):c}}((r,s)=>{let a=s;return"bigint"==typeof a&&(a={__type:"bigint",value:s.toString()}),a instanceof Map&&(a={__type:"Map",value:Array.from(s.entries())}),n?.(r,a)??a},i),e??void 0)}function QJ(t){const{deserialize:n=qYe,key:e="wagmi",serialize:i=ZYe,storage:r=JJ}=t;function s(a){return a instanceof Promise?a.then(o=>o).catch(()=>null):a}return{...r,key:e,getItem:(a,o)=>(0,Ge.Z)(function*(){const c=r.getItem(`${e}.${a}`),l=yield s(c);return l?n(l)??null:o??null})(),setItem:(a,o)=>(0,Ge.Z)(function*(){const c=`${e}.${a}`;null===o?yield s(r.removeItem(c)):yield s(r.setItem(c,i(o)))})(),removeItem:a=>(0,Ge.Z)(function*(){yield s(r.removeItem(`${e}.${a}`))})()}}const JJ={getItem:()=>null,setItem:()=>{},removeItem:()=>{}},YYe={getItem:t=>typeof window>"u"?null:function eee(t,n){const e=t.split("; ").find(i=>i.startsWith(`${n}=`));if(e)return e.substring(n.length+1)}(document.cookie,t)??null,setItem(t,n){typeof window>"u"||(document.cookie=`${t}=${n}`)},removeItem(t){typeof window>"u"||(document.cookie=`${t}=;max-age=-1`)}};let uA=!1;function dA(){return(dA=(0,Ge.Z)(function*(t,n={}){if(uA)return[];uA=!0,t.setState(l=>({...l,status:l.current?"reconnecting":"connecting"}));const e=[];if(n.connectors?.length)for(const l of n.connectors){let u;u="function"==typeof l?t._internal.connectors.setup(l):l,e.push(u)}else e.push(...t.connectors);let i;try{i=yield t.storage?.getItem("recentConnectorId")}catch{}const r={};for(const[,l]of t.state.connections)r[l.connector.id]=1;i&&(r[i]=0);const s=Object.keys(r).length>0?[...e].sort((l,u)=>(r[l.id]??10)-(r[u.id]??10)):e;let a=!1;const o=[],c=[];for(const l of s){const u=yield l.getProvider();if(!u||c.some(y=>y===u)||!(yield l.isAuthorized()))continue;const h=yield l.connect({isReconnecting:!0}).catch(()=>null);h&&(l.emitter.off("connect",t._internal.events.connect),l.emitter.on("change",t._internal.events.change),l.emitter.on("disconnect",t._internal.events.disconnect),t.setState(y=>{const I=new Map(a?y.connections:new Map).set(l.uid,{accounts:h.accounts,chainId:h.chainId,connector:l});return{...y,current:a?y.current:l.uid,connections:I}}),o.push({accounts:h.accounts,chainId:h.chainId,connector:l}),c.push(u),a=!0)}return("reconnecting"===t.state.status||"connecting"===t.state.status)&&t.setState(a?l=>({...l,status:"connected"}):l=>({...l,connections:new Map,current:null,status:"disconnected"})),uA=!1,o})).apply(this,arguments)}var XYe=$(1087),Sh=$.n(XYe);function tee(t,n){return fA.apply(this,arguments)}function fA(){return(fA=(0,Ge.Z)(function*(t,n){let e;if(e="function"==typeof n.connector?t._internal.connectors.setup(n.connector):n.connector,e.uid===t.state.current)throw new NYe;try{t.setState(s=>({...s,status:"connecting"})),e.emitter.emit("message",{type:"connecting"});const i=yield e.connect({chainId:n.chainId}),r=i.accounts;return e.emitter.off("connect",t._internal.events.connect),e.emitter.on("change",t._internal.events.change),e.emitter.on("disconnect",t._internal.events.disconnect),yield t.storage?.setItem("recentConnectorId",e.id),t.setState(s=>({...s,connections:new Map(s.connections).set(e.uid,{accounts:r,chainId:i.chainId,connector:e}),current:e.uid,status:"connected"})),{accounts:r,chainId:i.chainId}}catch(i){throw t.setState(r=>({...r,status:r.current?"connected":"disconnected"})),i}})).apply(this,arguments)}function hA(){return(hA=(0,Ge.Z)(function*(t,n={}){let e;if(n.connector)e=n.connector;else{const{connections:r,current:s}=t.state;e=r.get(s)?.connector}const i=t.state.connections;e&&(yield e.disconnect(),e.emitter.off("change",t._internal.events.change),e.emitter.off("disconnect",t._internal.events.disconnect),e.emitter.on("connect",t._internal.events.connect),i.delete(e.uid)),t.setState(r=>{if(0===i.size)return{...r,connections:new Map,current:null,status:"disconnected"};const s=i.values().next().value;return{...r,connections:new Map(i),current:s.connector.uid}});{const r=t.state.current;if(!r)return;const s=t.state.connections.get(r)?.connector;if(!s)return;yield t.storage?.setItem("recentConnectorId",s.id)}})).apply(this,arguments)}function JYe(t,n){return pA.apply(this,arguments)}function pA(){return(pA=(0,Ge.Z)(function*(t,{account:n=t.account,message:e}){if(!n)throw new JE({docsPath:"/docs/actions/wallet/signMessage"});const i=(0,kl.T)(n);if("local"===i.type)return i.signMessage({message:e});const r="string"==typeof e?(0,Qn.$G)(e):e.raw instanceof Uint8Array?(0,Qn.NC)(e.raw):e.raw;return t.request({method:"personal_sign",params:[r,i.address]},{retryCount:0})})).apply(this,arguments)}function mA(){return(mA=(0,Ge.Z)(function*(t,n){const{account:e,connector:i,...r}=n;let s;return s="object"==typeof e&&"local"===e.type?t.getClient():yield Td(t,{account:e,connector:i}),Ha(s,JYe,"signMessage")({...r,...e?{account:e}:{}})})).apply(this,arguments)}function gA(){return(gA=(0,Ge.Z)(function*(t,n){const{allowFailure:e=!0,chainId:i,contracts:r,...s}=n;return Ha(t.getClient({chainId:i}),bJ,"multicall")({allowFailure:e,contracts:r,...s})})).apply(this,arguments)}function vA(){return vA=(0,Ge.Z)(function*(t,n){const{allowFailure:e=!0,blockNumber:i,blockTag:r,...s}=n,a=n.contracts;try{const o=a.reduce((d,h,y)=>{const I=h.chainId??t.state.chainId;return{...d,[I]:[...d[I]||[],{contract:h,index:y}]}},{}),c=()=>Object.entries(o).map(([d,h])=>function iKe(t,n){return gA.apply(this,arguments)}(t,{...s,allowFailure:e,blockNumber:i,blockTag:r,chainId:parseInt(d),contracts:h.map(({contract:y})=>y)})),l=(yield Promise.all(c())).flat(),u=Object.values(o).flatMap(d=>d.map(({index:h})=>h));return l.reduce((d,h,y)=>(d&&(d[u[y]]=h),d),[])}catch(o){if(o instanceof Sc.uq)throw o;const c=()=>a.map(l=>function rKe(t,n){const{chainId:e,...i}=n;return Ha(t.getClient({chainId:e}),Al,"readContract")(i)}(t,{...l,blockNumber:i,blockTag:r}));return e?(yield Promise.allSettled(c())).map(l=>"fulfilled"===l.status?{result:l.value,status:"success"}:{error:l.reason,result:void 0,status:"failure"}):yield Promise.all(c())}}),vA.apply(this,arguments)}function yA(){return(yA=(0,Ge.Z)(function*(t,n){const{address:e,blockNumber:i,blockTag:r,chainId:s,token:a,unit:o="ether"}=n;if(a)try{return nee(t,{balanceAddress:e,chainId:s,symbolType:"string",tokenAddress:a})}catch(h){if(h instanceof Sc.uq){const y=yield nee(t,{balanceAddress:e,chainId:s,symbolType:"bytes32",tokenAddress:a}),I=(0,$2.rR)((0,PQ.f)(y.symbol,{dir:"right"}));return{...y,symbol:I}}throw h}const c=t.getClient({chainId:s}),u=yield Ha(c,mJ,"getBalance")(i?{address:e,blockNumber:i}:{address:e,blockTag:r}),d=t.chains.find(h=>h.id===s)??c.chain;return{decimals:d.nativeCurrency.decimals,formatted:(0,kh.b)(u,aA(o)),symbol:d.nativeCurrency.symbol,value:u}})).apply(this,arguments)}function nee(t,n){return _A.apply(this,arguments)}function _A(){return _A=(0,Ge.Z)(function*(t,n){const{balanceAddress:e,chainId:i,symbolType:r,tokenAddress:s,unit:a}=n,o={abi:[{type:"function",name:"balanceOf",stateMutability:"view",inputs:[{type:"address"}],outputs:[{type:"uint256"}]},{type:"function",name:"decimals",stateMutability:"view",inputs:[],outputs:[{type:"uint8"}]},{type:"function",name:"symbol",stateMutability:"view",inputs:[],outputs:[{type:r}]}],address:s},[c,l,u]=yield function sKe(t,n){return vA.apply(this,arguments)}(t,{allowFailure:!1,contracts:[{...o,functionName:"balanceOf",args:[e],chainId:i},{...o,functionName:"decimals",chainId:i},{...o,functionName:"symbol",chainId:i}]});return{decimals:l,formatted:(0,kh.b)(c??"0",aA(a??l)),symbol:u,value:c}}),_A.apply(this,arguments)}var ue=$(9185),Xt=$(7989),Ke=$(6494),bt=$(5937),Yv=$(9810);const jn=t=>t??Yv.Ld;var c2=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let E1=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.disabled=!1,this.balance="show",this.charsStart=4,this.charsEnd=6,this.address=ue.AccountController.state.address,this.balanceVal=ue.AccountController.state.balance,this.balanceSymbol=ue.AccountController.state.balanceSymbol,this.profileName=ue.AccountController.state.profileName,this.profileImage=ue.AccountController.state.profileImage,this.network=ue.NetworkController.state.caipNetwork,this.isUnsupportedChain=ue.NetworkController.state.isUnsupportedChain,this.unsubscribe.push(ue.AccountController.subscribe(n=>{n.isConnected?(this.address=n.address,this.balanceVal=n.balance,this.profileName=n.profileName,this.profileImage=n.profileImage,this.balanceSymbol=n.balanceSymbol):(this.address="",this.balanceVal="",this.profileName="",this.profileImage="",this.balanceSymbol="")}),ue.NetworkController.subscribeKey("caipNetwork",n=>this.network=n),ue.NetworkController.subscribeKey("isUnsupportedChain",n=>this.isUnsupportedChain=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){const n=ue.fz.getNetworkImage(this.network),e="show"===this.balance;return Ke.dy`
      <wui-account-button
        .disabled=${!!this.disabled}
        .isUnsupportedChain=${this.isUnsupportedChain}
        address=${jn(this.address)}
        profileName=${jn(this.profileName)}
        ?isProfileName=${!!this.profileName}
        networkSrc=${jn(n)}
        avatarSrc=${jn(this.profileImage)}
        balance=${e?ue.j1.formatBalance(this.balanceVal,this.balanceSymbol):""}
        @click=${this.onClick.bind(this)}
        data-testid="account-button"
        .charsStart=${this.charsStart}
        .charsEnd=${this.charsEnd}
      >
      </wui-account-button>
    `}onClick(){this.isUnsupportedChain?ue.IN.open({view:"UnsupportedChain"}):ue.IN.open()}};c2([(0,bt.Cb)({type:Boolean})],E1.prototype,"disabled",void 0),c2([(0,bt.Cb)()],E1.prototype,"balance",void 0),c2([(0,bt.Cb)()],E1.prototype,"charsStart",void 0),c2([(0,bt.Cb)()],E1.prototype,"charsEnd",void 0),c2([(0,bt.SB)()],E1.prototype,"address",void 0),c2([(0,bt.SB)()],E1.prototype,"balanceVal",void 0),c2([(0,bt.SB)()],E1.prototype,"balanceSymbol",void 0),c2([(0,bt.SB)()],E1.prototype,"profileName",void 0),c2([(0,bt.SB)()],E1.prototype,"profileImage",void 0),c2([(0,bt.SB)()],E1.prototype,"network",void 0),c2([(0,bt.SB)()],E1.prototype,"isUnsupportedChain",void 0),E1=c2([(0,Xt.customElement)("w3m-account-button")],E1);const oKe=Ke.iv`
  :host {
    display: block;
    width: max-content;
  }
`;var Dl=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let j2=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.disabled=!1,this.balance=void 0,this.size=void 0,this.label=void 0,this.loadingLabel=void 0,this.charsStart=4,this.charsEnd=6,this.isAccount=ue.AccountController.state.isConnected,this.unsubscribe.push(ue.AccountController.subscribeKey("isConnected",n=>{this.isAccount=n}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return this.isAccount?Ke.dy`
          <w3m-account-button
            .disabled=${!!this.disabled}
            balance=${jn(this.balance)}
            .charsStart=${jn(this.charsStart)}
            .charsEnd=${jn(this.charsEnd)}
          >
          </w3m-account-button>
        `:Ke.dy`
          <w3m-connect-button
            size=${jn(this.size)}
            label=${jn(this.label)}
            loadingLabel=${jn(this.loadingLabel)}
          ></w3m-connect-button>
        `}};j2.styles=oKe,Dl([(0,bt.Cb)({type:Boolean})],j2.prototype,"disabled",void 0),Dl([(0,bt.Cb)()],j2.prototype,"balance",void 0),Dl([(0,bt.Cb)()],j2.prototype,"size",void 0),Dl([(0,bt.Cb)()],j2.prototype,"label",void 0),Dl([(0,bt.Cb)()],j2.prototype,"loadingLabel",void 0),Dl([(0,bt.Cb)()],j2.prototype,"charsStart",void 0),Dl([(0,bt.Cb)()],j2.prototype,"charsEnd",void 0),Dl([(0,bt.SB)()],j2.prototype,"isAccount",void 0),j2=Dl([(0,Xt.customElement)("w3m-button")],j2);var Md=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let W4=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.size="md",this.label="Connect Wallet",this.loadingLabel="Connecting...",this.open=ue.IN.state.open,this.loading=ue.IN.state.loading,this.unsubscribe.push(ue.IN.subscribe(n=>{this.open=n.open,this.loading=n.loading}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){const n=this.loading||this.open;return Ke.dy`
      <wui-connect-button
        size=${jn(this.size)}
        .loading=${n}
        @click=${this.onClick.bind(this)}
        data-testid="connect-button"
      >
        ${n?this.loadingLabel:this.label}
      </wui-connect-button>
    `}onClick(){this.open?ue.IN.close():this.loading||ue.IN.open()}};Md([(0,bt.Cb)()],W4.prototype,"size",void 0),Md([(0,bt.Cb)()],W4.prototype,"label",void 0),Md([(0,bt.Cb)()],W4.prototype,"loadingLabel",void 0),Md([(0,bt.SB)()],W4.prototype,"open",void 0),Md([(0,bt.SB)()],W4.prototype,"loading",void 0),W4=Md([(0,Xt.customElement)("w3m-connect-button")],W4),$(4710);const cKe=Ke.iv`
  :host {
    display: block;
    width: max-content;
  }
`;var kd=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let X3=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.disabled=!1,this.network=ue.NetworkController.state.caipNetwork,this.connected=ue.AccountController.state.isConnected,this.loading=ue.IN.state.loading,this.isUnsupportedChain=ue.NetworkController.state.isUnsupportedChain,this.unsubscribe.push(ue.NetworkController.subscribeKey("caipNetwork",n=>this.network=n),ue.AccountController.subscribeKey("isConnected",n=>this.connected=n),ue.IN.subscribeKey("loading",n=>this.loading=n),ue.NetworkController.subscribeKey("isUnsupportedChain",n=>this.isUnsupportedChain=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-network-button
        .disabled=${!(!this.disabled&&!this.loading)}
        .isUnsupportedChain=${this.isUnsupportedChain}
        imageSrc=${jn(ue.fz.getNetworkImage(this.network))}
        @click=${this.onClick.bind(this)}
      >
        ${this.isUnsupportedChain?"Switch Network":this.network?.name??(this.connected?"Unknown Network":"Select Network")}
      </wui-network-button>
    `}onClick(){this.loading||(ue.Xs.sendEvent({type:"track",event:"CLICK_NETWORKS"}),ue.IN.open({view:"Networks"}))}};X3.styles=cKe,kd([(0,bt.Cb)({type:Boolean})],X3.prototype,"disabled",void 0),kd([(0,bt.SB)()],X3.prototype,"network",void 0),kd([(0,bt.SB)()],X3.prototype,"connected",void 0),kd([(0,bt.SB)()],X3.prototype,"loading",void 0),kd([(0,bt.SB)()],X3.prototype,"isUnsupportedChain",void 0),X3=kd([(0,Xt.customElement)("w3m-network-button")],X3);const lKe=Ke.iv`
  :host {
    display: block;
    will-change: transform, opacity;
  }
`;var iee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Kv=class extends Ke.oi{constructor(){super(),this.resizeObserver=void 0,this.prevHeight="0px",this.prevHistoryLength=1,this.unsubscribe=[],this.view=ue.RouterController.state.view,this.unsubscribe.push(ue.RouterController.subscribeKey("view",n=>this.onViewChange(n)))}firstUpdated(){var n=this;this.resizeObserver=new ResizeObserver(function(){var e=(0,Ge.Z)(function*([i]){const r=`${i?.contentRect.height}px`;"0px"!==n.prevHeight&&(yield n.animate([{height:n.prevHeight},{height:r}],{duration:150,easing:"ease",fill:"forwards"}).finished,n.style.height="auto"),n.prevHeight=r});return function(i){return e.apply(this,arguments)}}()),this.resizeObserver.observe(this.getWrapper())}disconnectedCallback(){this.resizeObserver?.unobserve(this.getWrapper()),this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`<div>${this.viewTemplate()}</div>`}viewTemplate(){switch(this.view){case"Connect":default:return Ke.dy`<w3m-connect-view></w3m-connect-view>`;case"ConnectingWalletConnect":return Ke.dy`<w3m-connecting-wc-view></w3m-connecting-wc-view>`;case"ConnectingExternal":return Ke.dy`<w3m-connecting-external-view></w3m-connecting-external-view>`;case"ConnectingSiwe":return Ke.dy`<w3m-connecting-siwe-view></w3m-connecting-siwe-view>`;case"AllWallets":return Ke.dy`<w3m-all-wallets-view></w3m-all-wallets-view>`;case"Networks":return Ke.dy`<w3m-networks-view></w3m-networks-view>`;case"SwitchNetwork":return Ke.dy`<w3m-network-switch-view></w3m-network-switch-view>`;case"Account":return Ke.dy`<w3m-account-view></w3m-account-view>`;case"AccountSettings":return Ke.dy`<w3m-account-settings-view></w3m-account-settings-view>`;case"WhatIsAWallet":return Ke.dy`<w3m-what-is-a-wallet-view></w3m-what-is-a-wallet-view>`;case"WhatIsANetwork":return Ke.dy`<w3m-what-is-a-network-view></w3m-what-is-a-network-view>`;case"GetWallet":return Ke.dy`<w3m-get-wallet-view></w3m-get-wallet-view>`;case"Downloads":return Ke.dy`<w3m-downloads-view></w3m-downloads-view>`;case"EmailVerifyOtp":return Ke.dy`<w3m-email-verify-otp-view></w3m-email-verify-otp-view>`;case"EmailVerifyDevice":return Ke.dy`<w3m-email-verify-device-view></w3m-email-verify-device-view>`;case"ApproveTransaction":return Ke.dy`<w3m-approve-transaction-view></w3m-approve-transaction-view>`;case"Transactions":return Ke.dy`<w3m-transactions-view></w3m-transactions-view>`;case"UpgradeEmailWallet":return Ke.dy`<w3m-upgrade-wallet-view></w3m-upgrade-wallet-view>`;case"UpgradeToSmartAccount":return Ke.dy`<w3m-upgrade-to-smart-account-view></w3m-upgrade-to-smart-account-view>`;case"UpdateEmailWallet":return Ke.dy`<w3m-update-email-wallet-view></w3m-update-email-wallet-view>`;case"UpdateEmailPrimaryOtp":return Ke.dy`<w3m-update-email-primary-otp-view></w3m-update-email-primary-otp-view>`;case"UpdateEmailSecondaryOtp":return Ke.dy`<w3m-update-email-secondary-otp-view></w3m-update-email-secondary-otp-view>`;case"UnsupportedChain":return Ke.dy`<w3m-unsupported-chain-view></w3m-unsupported-chain-view>`;case"OnRampProviders":return Ke.dy`<w3m-onramp-providers-view></w3m-onramp-providers-view>`;case"OnRampActivity":return Ke.dy`<w3m-onramp-activity-view></w3m-onramp-activity-view>`;case"OnRampTokenSelect":return Ke.dy`<w3m-onramp-token-select-view></w3m-onramp-token-select-view>`;case"OnRampFiatSelect":return Ke.dy`<w3m-onramp-fiat-select-view></w3m-onramp-fiat-select-view>`;case"WhatIsABuy":return Ke.dy`<w3m-what-is-a-buy-view></w3m-what-is-a-buy-view>`;case"BuyInProgress":return Ke.dy`<w3m-buy-in-progress-view></w3m-buy-in-progress-view>`;case"WalletReceive":return Ke.dy`<w3m-wallet-receive-view></w3m-wallet-receive-view>`;case"WalletCompatibleNetworks":return Ke.dy`<w3m-wallet-compatible-networks-view></w3m-wallet-compatible-networks-view>`;case"WalletSend":return Ke.dy`<w3m-wallet-send-view></w3m-wallet-send-view>`;case"WalletSendSelectToken":return Ke.dy`<w3m-wallet-send-select-token-view></w3m-wallet-send-select-token-view>`;case"WalletSendPreview":return Ke.dy`<w3m-wallet-send-preview-view></w3m-wallet-send-preview-view>`}}onViewChange(n){var e=this;return(0,Ge.Z)(function*(){const{history:i}=ue.RouterController.state;let r=-10,s=10;i.length<e.prevHistoryLength&&(r=10,s=-10),e.prevHistoryLength=i.length,yield e.animate([{opacity:1,transform:"translateX(0px)"},{opacity:0,transform:`translateX(${r}px)`}],{duration:150,easing:"ease",fill:"forwards"}).finished,e.view=n,yield e.animate([{opacity:0,transform:`translateX(${s}px)`},{opacity:1,transform:"translateX(0px)"}],{duration:150,easing:"ease",fill:"forwards",delay:50}).finished})()}getWrapper(){return this.shadowRoot?.querySelector("div")}};Kv.styles=lKe,iee([(0,bt.SB)()],Kv.prototype,"view",void 0),Kv=iee([(0,Xt.customElement)("w3m-router")],Kv);const uKe=Ke.iv`
  :host > wui-flex {
    width: 100%;
    max-width: 360px;
  }

  :host > wui-flex > wui-flex {
    border-radius: var(--wui-border-radius-l);
    width: 100%;
  }

  .amounts-container {
    width: 100%;
  }
`;var Q3=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};const dKe={USD:"$",EUR:"\u20ac",GBP:"\xa3"},fKe=[100,250,500,1e3];let Ac=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.disabled=!1,this.connected=ue.AccountController.state.isConnected,this.loading=ue.IN.state.loading,this.paymentCurrency=ue.ph.state.paymentCurrency,this.paymentAmount=ue.ph.state.paymentAmount,this.purchaseAmount=ue.ph.state.purchaseAmount,this.quoteLoading=ue.ph.state.quotesLoading,this.unsubscribe.push(ue.AccountController.subscribeKey("isConnected",n=>{this.connected=n}),ue.IN.subscribeKey("loading",n=>{this.loading=n}),ue.ph.subscribe(n=>{this.paymentCurrency=n.paymentCurrency,this.paymentAmount=n.paymentAmount,this.purchaseAmount=n.purchaseAmount,this.quoteLoading=n.quotesLoading}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-flex flexDirection="column" justifyContent="center" alignItems="center">
        <wui-flex flexDirection="column" alignItems="center" gap="xs">
          <w3m-swap-input
            type="Fiat"
            @inputChange=${this.onPaymentAmountChange.bind(this)}
            .value=${this.paymentAmount||0}
          ></w3m-swap-input>
          <w3m-swap-input
            type="Token"
            .value=${this.purchaseAmount||0}
            .loading=${this.quoteLoading}
          ></w3m-swap-input>
          <wui-flex justifyContent="space-evenly" class="amounts-container" gap="xs">
            ${fKe.map(n=>Ke.dy`<wui-button
                  variant=${this.paymentAmount===n?"accentBg":"shade"}
                  size="xs"
                  textVariant="paragraph-600"
                  fullWidth
                  @click=${()=>this.selectPresetAmount(n)}
                  >${`${dKe[this.paymentCurrency?.id||"USD"]} ${n}`}</wui-button
                >`)}
          </wui-flex>
          ${this.templateButton()}
        </wui-flex>
      </wui-flex>
    `}templateButton(){return this.connected?Ke.dy`<wui-button
          @click=${this.getQuotes.bind(this)}
          variant="fill"
          fullWidth
          size="lg"
          borderRadius="xs"
        >
          Get quotes
        </wui-button>`:Ke.dy`<wui-button
          @click=${this.openModal.bind(this)}
          variant="accentBg"
          fullWidth
          size="lg"
          borderRadius="xs"
        >
          Connect wallet
        </wui-button>`}getQuotes(){this.loading||ue.IN.open({view:"OnRampProviders"})}openModal(){ue.IN.open({view:"Connect"})}onPaymentAmountChange(n){return(0,Ge.Z)(function*(){ue.ph.setPaymentAmount(Number(n.detail)),yield ue.ph.getQuote()})()}selectPresetAmount(n){return(0,Ge.Z)(function*(){ue.ph.setPaymentAmount(n),yield ue.ph.getQuote()})()}};Ac.styles=uKe,Q3([(0,bt.Cb)({type:Boolean})],Ac.prototype,"disabled",void 0),Q3([(0,bt.SB)()],Ac.prototype,"connected",void 0),Q3([(0,bt.SB)()],Ac.prototype,"loading",void 0),Q3([(0,bt.SB)()],Ac.prototype,"paymentCurrency",void 0),Q3([(0,bt.SB)()],Ac.prototype,"paymentAmount",void 0),Q3([(0,bt.SB)()],Ac.prototype,"purchaseAmount",void 0),Q3([(0,bt.SB)()],Ac.prototype,"quoteLoading",void 0),Ac=Q3([(0,Xt.customElement)("w3m-onramp-widget")],Ac);const hKe=Ke.iv`
  wui-flex {
    width: 100%;
  }

  wui-icon-link {
    margin-right: calc(var(--wui-icon-box-size-md) * -1);
  }

  .account-links {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .account-links wui-flex {
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 1;
    background: red;
    align-items: center;
    justify-content: center;
    height: 48px;
    padding: 10px;
    flex: 1 0 0;

    border-radius: var(--XS, 16px);
    border: 1px solid var(--dark-accent-glass-010, rgba(71, 161, 255, 0.1));
    background: var(--dark-accent-glass-010, rgba(71, 161, 255, 0.1));
    transition: background-color var(--wui-ease-out-power-1) var(--wui-duration-md);
    will-change: background-color;
  }

  .account-links wui-flex:hover {
    background: var(--dark-accent-glass-015, rgba(71, 161, 255, 0.15));
  }

  .account-links wui-flex wui-icon {
    width: var(--S, 20px);
    height: var(--S, 20px);
  }

  .account-links wui-flex wui-icon svg path {
    stroke: #47a1ff;
  }
`;var pKe=$(9007);typeof window<"u"&&(window.Buffer||(window.Buffer=pKe.Buffer),window.global||(window.global=window),window.process||(window.process={}),window.process?.env||(window.process={env:{}}));const cn={SECURE_SITE_SDK:process.env.NEXT_PUBLIC_SECURE_SITE_SDK_URL||"https://secure.walletconnect.com/sdk",APP_EVENT_KEY:"@w3m-app/",FRAME_EVENT_KEY:"@w3m-frame/",RPC_METHOD_KEY:"RPC_",STORAGE_KEY:"@w3m-storage/",SESSION_TOKEN_KEY:"SESSION_TOKEN_KEY",EMAIL_LOGIN_USED_KEY:"EMAIL_LOGIN_USED_KEY",LAST_USED_CHAIN_KEY:"LAST_USED_CHAIN_KEY",LAST_EMAIL_LOGIN_TIME:"LAST_EMAIL_LOGIN_TIME",EMAIL:"EMAIL",PREFERRED_ACCOUNT_TYPE:"PREFERRED_ACCOUNT_TYPE",SMART_ACCOUNT_ENABLED:"SMART_ACCOUNT_ENABLED",SMART_ACCOUNT_ENABLED_NETWORKS:"SMART_ACCOUNT_ENABLED_NETWORKS",APP_SWITCH_NETWORK:"@w3m-app/SWITCH_NETWORK",APP_CONNECT_EMAIL:"@w3m-app/CONNECT_EMAIL",APP_CONNECT_DEVICE:"@w3m-app/CONNECT_DEVICE",APP_CONNECT_OTP:"@w3m-app/CONNECT_OTP",APP_GET_USER:"@w3m-app/GET_USER",APP_SIGN_OUT:"@w3m-app/SIGN_OUT",APP_IS_CONNECTED:"@w3m-app/IS_CONNECTED",APP_GET_CHAIN_ID:"@w3m-app/GET_CHAIN_ID",APP_RPC_REQUEST:"@w3m-app/RPC_REQUEST",APP_UPDATE_EMAIL:"@w3m-app/UPDATE_EMAIL",APP_UPDATE_EMAIL_PRIMARY_OTP:"@w3m-app/UPDATE_EMAIL_PRIMARY_OTP",APP_UPDATE_EMAIL_SECONDARY_OTP:"@w3m-app/UPDATE_EMAIL_SECONDARY_OTP",APP_AWAIT_UPDATE_EMAIL:"@w3m-app/AWAIT_UPDATE_EMAIL",APP_SYNC_THEME:"@w3m-app/SYNC_THEME",APP_SYNC_DAPP_DATA:"@w3m-app/SYNC_DAPP_DATA",APP_GET_SMART_ACCOUNT_ENABLED_NETWORKS:"@w3m-app/GET_SMART_ACCOUNT_ENABLED_NETWORKS",APP_INIT_SMART_ACCOUNT:"@w3m-app/INIT_SMART_ACCOUNT",APP_SET_PREFERRED_ACCOUNT:"@w3m-app/SET_PREFERRED_ACCOUNT",FRAME_SWITCH_NETWORK_ERROR:"@w3m-frame/SWITCH_NETWORK_ERROR",FRAME_SWITCH_NETWORK_SUCCESS:"@w3m-frame/SWITCH_NETWORK_SUCCESS",FRAME_CONNECT_EMAIL_ERROR:"@w3m-frame/CONNECT_EMAIL_ERROR",FRAME_CONNECT_EMAIL_SUCCESS:"@w3m-frame/CONNECT_EMAIL_SUCCESS",FRAME_CONNECT_DEVICE_ERROR:"@w3m-frame/CONNECT_DEVICE_ERROR",FRAME_CONNECT_DEVICE_SUCCESS:"@w3m-frame/CONNECT_DEVICE_SUCCESS",FRAME_CONNECT_OTP_SUCCESS:"@w3m-frame/CONNECT_OTP_SUCCESS",FRAME_CONNECT_OTP_ERROR:"@w3m-frame/CONNECT_OTP_ERROR",FRAME_GET_USER_SUCCESS:"@w3m-frame/GET_USER_SUCCESS",FRAME_GET_USER_ERROR:"@w3m-frame/GET_USER_ERROR",FRAME_SIGN_OUT_SUCCESS:"@w3m-frame/SIGN_OUT_SUCCESS",FRAME_SIGN_OUT_ERROR:"@w3m-frame/SIGN_OUT_ERROR",FRAME_IS_CONNECTED_SUCCESS:"@w3m-frame/IS_CONNECTED_SUCCESS",FRAME_IS_CONNECTED_ERROR:"@w3m-frame/IS_CONNECTED_ERROR",FRAME_GET_CHAIN_ID_SUCCESS:"@w3m-frame/GET_CHAIN_ID_SUCCESS",FRAME_GET_CHAIN_ID_ERROR:"@w3m-frame/GET_CHAIN_ID_ERROR",FRAME_RPC_REQUEST_SUCCESS:"@w3m-frame/RPC_REQUEST_SUCCESS",FRAME_RPC_REQUEST_ERROR:"@w3m-frame/RPC_REQUEST_ERROR",FRAME_SESSION_UPDATE:"@w3m-frame/SESSION_UPDATE",FRAME_UPDATE_EMAIL_SUCCESS:"@w3m-frame/UPDATE_EMAIL_SUCCESS",FRAME_UPDATE_EMAIL_ERROR:"@w3m-frame/UPDATE_EMAIL_ERROR",FRAME_UPDATE_EMAIL_PRIMARY_OTP_SUCCESS:"@w3m-frame/UPDATE_EMAIL_PRIMARY_OTP_SUCCESS",FRAME_UPDATE_EMAIL_PRIMARY_OTP_ERROR:"@w3m-frame/UPDATE_EMAIL_PRIMARY_OTP_ERROR",FRAME_UPDATE_EMAIL_SECONDARY_OTP_SUCCESS:"@w3m-frame/UPDATE_EMAIL_SECONDARY_OTP_SUCCESS",FRAME_UPDATE_EMAIL_SECONDARY_OTP_ERROR:"@w3m-frame/UPDATE_EMAIL_SECONDARY_OTP_ERROR",FRAME_SYNC_THEME_SUCCESS:"@w3m-frame/SYNC_THEME_SUCCESS",FRAME_SYNC_THEME_ERROR:"@w3m-frame/SYNC_THEME_ERROR",FRAME_SYNC_DAPP_DATA_SUCCESS:"@w3m-frame/SYNC_DAPP_DATA_SUCCESS",FRAME_SYNC_DAPP_DATA_ERROR:"@w3m-frame/SYNC_DAPP_DATA_ERROR",FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_SUCCESS:"@w3m-frame/GET_SMART_ACCOUNT_ENABLED_NETWORKS_SUCCESS",FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_ERROR:"@w3m-frame/GET_SMART_ACCOUNT_ENABLED_NETWORKS_ERROR",FRAME_INIT_SMART_ACCOUNT_SUCCESS:"@w3m-frame/INIT_SMART_ACCOUNT_SUCCESS",FRAME_INIT_SMART_ACCOUNT_ERROR:"@w3m-frame/INIT_SMART_ACCOUNT_ERROR",FRAME_SET_PREFERRED_ACCOUNT_SUCCESS:"@w3m-frame/SET_PREFERRED_ACCOUNT_SUCCESS",FRAME_SET_PREFERRED_ACCOUNT_ERROR:"@w3m-frame/SET_PREFERRED_ACCOUNT_ERROR"},wa={SAFE_RPC_METHODS:["eth_accounts","eth_blockNumber","eth_call","eth_chainId","eth_estimateGas","eth_feeHistory","eth_gasPrice","eth_getAccount","eth_getBalance","eth_getBlockByHash","eth_getBlockByNumber","eth_getBlockReceipts","eth_getBlockTransactionCountByHash","eth_getBlockTransactionCountByNumber","eth_getCode","eth_getFilterChanges","eth_getFilterLogs","eth_getLogs","eth_getProof","eth_getStorageAt","eth_getTransactionByBlockHashAndIndex","eth_getTransactionByBlockNumberAndIndex","eth_getTransactionByHash","eth_getTransactionCount","eth_getTransactionReceipt","eth_getUncleCountByBlockHash","eth_getUncleCountByBlockNumber","eth_maxPriorityFeePerGas","eth_newBlockFilter","eth_newFilter","eth_newPendingTransactionFilter","eth_sendRawTransaction","eth_syncing","eth_uninstallFilter"],NOT_SAFE_RPC_METHODS:["personal_sign","eth_signTypedData_v4","eth_sendTransaction"],GET_CHAIN_ID:"eth_chainId",RPC_METHOD_NOT_ALLOWED_MESSAGE:"Requested RPC call is not allowed",RPC_METHOD_NOT_ALLOWED_UI_MESSAGE:"Action not allowed",ACCOUNT_TYPES:{EOA:"eoa",SMART_ACCOUNT:"smartAccount"}};var Zi,t;(t=Zi||(Zi={})).assertEqual=r=>r,t.assertIs=function n(r){},t.assertNever=function e(r){throw new Error},t.arrayToEnum=r=>{const s={};for(const a of r)s[a]=a;return s},t.getValidEnumValues=r=>{const s=t.objectKeys(r).filter(o=>"number"!=typeof r[r[o]]),a={};for(const o of s)a[o]=r[o];return t.objectValues(a)},t.objectValues=r=>t.objectKeys(r).map(function(s){return r[s]}),t.objectKeys="function"==typeof Object.keys?r=>Object.keys(r):r=>{const s=[];for(const a in r)Object.prototype.hasOwnProperty.call(r,a)&&s.push(a);return s},t.find=(r,s)=>{for(const a of r)if(s(a))return a},t.isInteger="function"==typeof Number.isInteger?r=>Number.isInteger(r):r=>"number"==typeof r&&isFinite(r)&&Math.floor(r)===r,t.joinValues=function i(r,s=" | "){return r.map(a=>"string"==typeof a?`'${a}'`:a).join(s)},t.jsonStringifyReplacer=(r,s)=>"bigint"==typeof s?s.toString():s;var ree=function(t){return t.mergeShapes=(n,e)=>({...n,...e}),t}(ree||{});const yn=Zi.arrayToEnum(["string","nan","number","integer","float","boolean","date","bigint","symbol","function","undefined","null","array","object","unknown","promise","void","never","map","set"]),J3=t=>{switch(typeof t){case"undefined":return yn.undefined;case"string":return yn.string;case"number":return isNaN(t)?yn.nan:yn.number;case"boolean":return yn.boolean;case"function":return yn.function;case"bigint":return yn.bigint;case"symbol":return yn.symbol;case"object":return Array.isArray(t)?yn.array:null===t?yn.null:t.then&&"function"==typeof t.then&&t.catch&&"function"==typeof t.catch?yn.promise:typeof Map<"u"&&t instanceof Map?yn.map:typeof Set<"u"&&t instanceof Set?yn.set:typeof Date<"u"&&t instanceof Date?yn.date:yn.object;default:return yn.unknown}},sn=Zi.arrayToEnum(["invalid_type","invalid_literal","custom","invalid_union","invalid_union_discriminator","invalid_enum_value","unrecognized_keys","invalid_arguments","invalid_return_type","invalid_date","invalid_string","too_small","too_big","invalid_intersection_types","not_multiple_of","not_finite"]);let Nl=(()=>{class t extends Error{constructor(e){super(),this.issues=[],this.addIssue=r=>{this.issues=[...this.issues,r]},this.addIssues=(r=[])=>{this.issues=[...this.issues,...r]};const i=new.target.prototype;Object.setPrototypeOf?Object.setPrototypeOf(this,i):this.__proto__=i,this.name="ZodError",this.issues=e}get errors(){return this.issues}format(e){const i=e||function(a){return a.message},r={_errors:[]},s=a=>{for(const o of a.issues)if("invalid_union"===o.code)o.unionErrors.map(s);else if("invalid_return_type"===o.code)s(o.returnTypeError);else if("invalid_arguments"===o.code)s(o.argumentsError);else if(0===o.path.length)r._errors.push(i(o));else{let c=r,l=0;for(;l<o.path.length;){const u=o.path[l];l===o.path.length-1?(c[u]=c[u]||{_errors:[]},c[u]._errors.push(i(o))):c[u]=c[u]||{_errors:[]},c=c[u],l++}}};return s(this),r}toString(){return this.message}get message(){return JSON.stringify(this.issues,Zi.jsonStringifyReplacer,2)}get isEmpty(){return 0===this.issues.length}flatten(e=(i=>i.message)){const i={},r=[];for(const s of this.issues)s.path.length>0?(i[s.path[0]]=i[s.path[0]]||[],i[s.path[0]].push(e(s))):r.push(e(s));return{formErrors:r,fieldErrors:i}}get formErrors(){return this.flatten()}}return t.create=n=>new t(n),t})();const Eh=(t,n)=>{let e;switch(t.code){case sn.invalid_type:e=t.received===yn.undefined?"Required":`Expected ${t.expected}, received ${t.received}`;break;case sn.invalid_literal:e=`Invalid literal value, expected ${JSON.stringify(t.expected,Zi.jsonStringifyReplacer)}`;break;case sn.unrecognized_keys:e=`Unrecognized key(s) in object: ${Zi.joinValues(t.keys,", ")}`;break;case sn.invalid_union:e="Invalid input";break;case sn.invalid_union_discriminator:e=`Invalid discriminator value. Expected ${Zi.joinValues(t.options)}`;break;case sn.invalid_enum_value:e=`Invalid enum value. Expected ${Zi.joinValues(t.options)}, received '${t.received}'`;break;case sn.invalid_arguments:e="Invalid function arguments";break;case sn.invalid_return_type:e="Invalid function return type";break;case sn.invalid_date:e="Invalid date";break;case sn.invalid_string:"object"==typeof t.validation?"includes"in t.validation?(e=`Invalid input: must include "${t.validation.includes}"`,"number"==typeof t.validation.position&&(e=`${e} at one or more positions greater than or equal to ${t.validation.position}`)):"startsWith"in t.validation?e=`Invalid input: must start with "${t.validation.startsWith}"`:"endsWith"in t.validation?e=`Invalid input: must end with "${t.validation.endsWith}"`:Zi.assertNever(t.validation):e="regex"!==t.validation?`Invalid ${t.validation}`:"Invalid";break;case sn.too_small:e="array"===t.type?`Array must contain ${t.exact?"exactly":t.inclusive?"at least":"more than"} ${t.minimum} element(s)`:"string"===t.type?`String must contain ${t.exact?"exactly":t.inclusive?"at least":"over"} ${t.minimum} character(s)`:"number"===t.type?`Number must be ${t.exact?"exactly equal to ":t.inclusive?"greater than or equal to ":"greater than "}${t.minimum}`:"date"===t.type?`Date must be ${t.exact?"exactly equal to ":t.inclusive?"greater than or equal to ":"greater than "}${new Date(Number(t.minimum))}`:"Invalid input";break;case sn.too_big:e="array"===t.type?`Array must contain ${t.exact?"exactly":t.inclusive?"at most":"less than"} ${t.maximum} element(s)`:"string"===t.type?`String must contain ${t.exact?"exactly":t.inclusive?"at most":"under"} ${t.maximum} character(s)`:"number"===t.type?`Number must be ${t.exact?"exactly":t.inclusive?"less than or equal to":"less than"} ${t.maximum}`:"bigint"===t.type?`BigInt must be ${t.exact?"exactly":t.inclusive?"less than or equal to":"less than"} ${t.maximum}`:"date"===t.type?`Date must be ${t.exact?"exactly":t.inclusive?"smaller than or equal to":"smaller than"} ${new Date(Number(t.maximum))}`:"Invalid input";break;case sn.custom:e="Invalid input";break;case sn.invalid_intersection_types:e="Intersection results could not be merged";break;case sn.not_multiple_of:e=`Number must be a multiple of ${t.multipleOf}`;break;case sn.not_finite:e="Number must be finite";break;default:e=n.defaultError,Zi.assertNever(t)}return{message:e}};let see=Eh;function Xv(){return see}const Qv=t=>{const{data:n,path:e,errorMaps:i,issueData:r}=t,s=[...e,...r.path||[]],a={...r,path:s};let o="";const c=i.filter(l=>!!l).slice().reverse();for(const l of c)o=l(a,{data:n,defaultError:o}).message;return{...r,path:s,message:r.message||o}};function bn(t,n){const e=Qv({issueData:n,data:t.data,path:t.path,errorMaps:[t.common.contextualErrorMap,t.schemaErrorMap,Xv(),Eh].filter(i=>!!i)});t.common.issues.push(e)}class Va{constructor(){this.value="valid"}dirty(){"valid"===this.value&&(this.value="dirty")}abort(){"aborted"!==this.value&&(this.value="aborted")}static mergeArray(n,e){const i=[];for(const r of e){if("aborted"===r.status)return hi;"dirty"===r.status&&n.dirty(),i.push(r.value)}return{status:n.value,value:i}}static mergeObjectAsync(n,e){return(0,Ge.Z)(function*(){const i=[];for(const r of e)i.push({key:yield r.key,value:yield r.value});return Va.mergeObjectSync(n,i)})()}static mergeObjectSync(n,e){const i={};for(const r of e){const{key:s,value:a}=r;if("aborted"===s.status||"aborted"===a.status)return hi;"dirty"===s.status&&n.dirty(),"dirty"===a.status&&n.dirty(),"__proto__"!==s.value&&(typeof a.value<"u"||r.alwaysSet)&&(i[s.value]=a.value)}return{status:n.value,value:i}}}const hi=Object.freeze({status:"aborted"}),aee=t=>({status:"dirty",value:t}),fo=t=>({status:"valid",value:t}),bA=t=>"aborted"===t.status,wA=t=>"dirty"===t.status,Ah=t=>"valid"===t.status,Jv=t=>typeof Promise<"u"&&t instanceof Promise;var Fn=function(t){return t.errToObj=n=>"string"==typeof n?{message:n}:n||{},t.toString=n=>"string"==typeof n?n:n?.message,t}(Fn||{});class Ic{constructor(n,e,i,r){this._cachedPath=[],this.parent=n,this.data=e,this._path=i,this._key=r}get path(){return this._cachedPath.length||(this._key instanceof Array?this._cachedPath.push(...this._path,...this._key):this._cachedPath.push(...this._path,this._key)),this._cachedPath}}const oee=(t,n)=>{if(Ah(n))return{success:!0,data:n.value};if(!t.common.issues.length)throw new Error("Validation failed but no issues detected.");return{success:!1,get error(){if(this._error)return this._error;const e=new Nl(t.common.issues);return this._error=e,this._error}}};function gi(t){if(!t)return{};const{errorMap:n,invalid_type_error:e,required_error:i,description:r}=t;if(n&&(e||i))throw new Error('Can\'t use "invalid_type_error" or "required_error" in conjunction with custom error map.');return n?{errorMap:n,description:r}:{errorMap:(a,o)=>"invalid_type"!==a.code?{message:o.defaultError}:typeof o.data>"u"?{message:i??o.defaultError}:{message:e??o.defaultError},description:r}}class wi{constructor(n){this.spa=this.safeParseAsync,this._def=n,this.parse=this.parse.bind(this),this.safeParse=this.safeParse.bind(this),this.parseAsync=this.parseAsync.bind(this),this.safeParseAsync=this.safeParseAsync.bind(this),this.spa=this.spa.bind(this),this.refine=this.refine.bind(this),this.refinement=this.refinement.bind(this),this.superRefine=this.superRefine.bind(this),this.optional=this.optional.bind(this),this.nullable=this.nullable.bind(this),this.nullish=this.nullish.bind(this),this.array=this.array.bind(this),this.promise=this.promise.bind(this),this.or=this.or.bind(this),this.and=this.and.bind(this),this.transform=this.transform.bind(this),this.brand=this.brand.bind(this),this.default=this.default.bind(this),this.catch=this.catch.bind(this),this.describe=this.describe.bind(this),this.pipe=this.pipe.bind(this),this.readonly=this.readonly.bind(this),this.isNullable=this.isNullable.bind(this),this.isOptional=this.isOptional.bind(this)}get description(){return this._def.description}_getType(n){return J3(n.data)}_getOrReturnCtx(n,e){return e||{common:n.parent.common,data:n.data,parsedType:J3(n.data),schemaErrorMap:this._def.errorMap,path:n.path,parent:n.parent}}_processInputParams(n){return{status:new Va,ctx:{common:n.parent.common,data:n.data,parsedType:J3(n.data),schemaErrorMap:this._def.errorMap,path:n.path,parent:n.parent}}}_parseSync(n){const e=this._parse(n);if(Jv(e))throw new Error("Synchronous parse encountered promise.");return e}_parseAsync(n){const e=this._parse(n);return Promise.resolve(e)}parse(n,e){const i=this.safeParse(n,e);if(i.success)return i.data;throw i.error}safeParse(n,e){var i;const r={common:{issues:[],async:null!==(i=e?.async)&&void 0!==i&&i,contextualErrorMap:e?.errorMap},path:e?.path||[],schemaErrorMap:this._def.errorMap,parent:null,data:n,parsedType:J3(n)},s=this._parseSync({data:n,path:r.path,parent:r});return oee(r,s)}parseAsync(n,e){var i=this;return(0,Ge.Z)(function*(){const r=yield i.safeParseAsync(n,e);if(r.success)return r.data;throw r.error})()}safeParseAsync(n,e){var i=this;return(0,Ge.Z)(function*(){const r={common:{issues:[],contextualErrorMap:e?.errorMap,async:!0},path:e?.path||[],schemaErrorMap:i._def.errorMap,parent:null,data:n,parsedType:J3(n)},s=i._parse({data:n,path:r.path,parent:r}),a=yield Jv(s)?s:Promise.resolve(s);return oee(r,a)})()}refine(n,e){const i=r=>"string"==typeof e||typeof e>"u"?{message:e}:"function"==typeof e?e(r):e;return this._refinement((r,s)=>{const a=n(r),o=()=>s.addIssue({code:sn.custom,...i(r)});return typeof Promise<"u"&&a instanceof Promise?a.then(c=>!!c||(o(),!1)):!!a||(o(),!1)})}refinement(n,e){return this._refinement((i,r)=>!!n(i)||(r.addIssue("function"==typeof e?e(i,r):e),!1))}_refinement(n){return new G4({schema:this,typeName:Jn.ZodEffects,effect:{type:"refinement",refinement:n}})}superRefine(n){return this._refinement(n)}optional(){return Z4.create(this,this._def)}nullable(){return Rh.create(this,this._def)}nullish(){return this.nullable().optional()}array(){return Dh.create(this,this._def)}promise(){return sy.create(this,this._def)}or(n){return AA.create([this,n],this._def)}and(n){return DA.create(this,n,this._def)}transform(n){return new G4({...gi(this._def),schema:this,typeName:Jn.ZodEffects,effect:{type:"transform",transform:n}})}default(n){const e="function"==typeof n?n:()=>n;return new PA({...gi(this._def),innerType:this,defaultValue:e,typeName:Jn.ZodDefault})}brand(){return new mee({typeName:Jn.ZodBranded,type:this,...gi(this._def)})}catch(n){const e="function"==typeof n?n:()=>n;return new hee({...gi(this._def),innerType:this,catchValue:e,typeName:Jn.ZodCatch})}describe(n){return new(0,this.constructor)({...this._def,description:n})}pipe(n){return Lh.create(this,n)}readonly(){return gee.create(this)}isOptional(){return this.safeParse(void 0).success}isNullable(){return this.safeParse(null).success}}const yKe=/^c[^\s-]{8,}$/i,_Ke=/^[a-z][a-z0-9]*$/,bKe=/^[0-9A-HJKMNP-TV-Z]{26}$/,wKe=/^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/i,CKe=/^(?!\.)(?!.*\.\.)([A-Z0-9_+-\.]*)[A-Z0-9_+-]@([A-Z0-9][A-Z0-9\-]*\.)+[A-Z]{2,}$/i;let CA;const TKe=/^(((25[0-5])|(2[0-4][0-9])|(1[0-9]{2})|([0-9]{1,2}))\.){3}((25[0-5])|(2[0-4][0-9])|(1[0-9]{2})|([0-9]{1,2}))$/,MKe=/^(([a-f0-9]{1,4}:){7}|::([a-f0-9]{1,4}:){0,6}|([a-f0-9]{1,4}:){1}:([a-f0-9]{1,4}:){0,5}|([a-f0-9]{1,4}:){2}:([a-f0-9]{1,4}:){0,4}|([a-f0-9]{1,4}:){3}:([a-f0-9]{1,4}:){0,3}|([a-f0-9]{1,4}:){4}:([a-f0-9]{1,4}:){0,2}|([a-f0-9]{1,4}:){5}:([a-f0-9]{1,4}:){0,1})([a-f0-9]{1,4}|(((25[0-5])|(2[0-4][0-9])|(1[0-9]{2})|([0-9]{1,2}))\.){3}((25[0-5])|(2[0-4][0-9])|(1[0-9]{2})|([0-9]{1,2})))$/,kKe=t=>t.precision?t.offset?new RegExp(`^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{${t.precision}}(([+-]\\d{2}(:?\\d{2})?)|Z)$`):new RegExp(`^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{${t.precision}}Z$`):0===t.precision?t.offset?new RegExp("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(([+-]\\d{2}(:?\\d{2})?)|Z)$"):new RegExp("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$"):t.offset?new RegExp("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?(([+-]\\d{2}(:?\\d{2})?)|Z)$"):new RegExp("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?Z$");function SKe(t,n){return!(("v4"!==n&&n||!TKe.test(t))&&("v6"!==n&&n||!MKe.test(t)))}let ey=(()=>{class t extends wi{_parse(e){if(this._def.coerce&&(e.data=String(e.data)),this._getType(e)!==yn.string){const a=this._getOrReturnCtx(e);return bn(a,{code:sn.invalid_type,expected:yn.string,received:a.parsedType}),hi}const r=new Va;let s;for(const a of this._def.checks)if("min"===a.kind)e.data.length<a.value&&(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.too_small,minimum:a.value,type:"string",inclusive:!0,exact:!1,message:a.message}),r.dirty());else if("max"===a.kind)e.data.length>a.value&&(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.too_big,maximum:a.value,type:"string",inclusive:!0,exact:!1,message:a.message}),r.dirty());else if("length"===a.kind){const o=e.data.length>a.value,c=e.data.length<a.value;(o||c)&&(s=this._getOrReturnCtx(e,s),o?bn(s,{code:sn.too_big,maximum:a.value,type:"string",inclusive:!0,exact:!0,message:a.message}):c&&bn(s,{code:sn.too_small,minimum:a.value,type:"string",inclusive:!0,exact:!0,message:a.message}),r.dirty())}else if("email"===a.kind)CKe.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"email",code:sn.invalid_string,message:a.message}),r.dirty());else if("emoji"===a.kind)CA||(CA=new RegExp("^(\\p{Extended_Pictographic}|\\p{Emoji_Component})+$","u")),CA.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"emoji",code:sn.invalid_string,message:a.message}),r.dirty());else if("uuid"===a.kind)wKe.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"uuid",code:sn.invalid_string,message:a.message}),r.dirty());else if("cuid"===a.kind)yKe.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"cuid",code:sn.invalid_string,message:a.message}),r.dirty());else if("cuid2"===a.kind)_Ke.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"cuid2",code:sn.invalid_string,message:a.message}),r.dirty());else if("ulid"===a.kind)bKe.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"ulid",code:sn.invalid_string,message:a.message}),r.dirty());else if("url"===a.kind)try{new URL(e.data)}catch{s=this._getOrReturnCtx(e,s),bn(s,{validation:"url",code:sn.invalid_string,message:a.message}),r.dirty()}else"regex"===a.kind?(a.regex.lastIndex=0,a.regex.test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"regex",code:sn.invalid_string,message:a.message}),r.dirty())):"trim"===a.kind?e.data=e.data.trim():"includes"===a.kind?e.data.includes(a.value,a.position)||(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.invalid_string,validation:{includes:a.value,position:a.position},message:a.message}),r.dirty()):"toLowerCase"===a.kind?e.data=e.data.toLowerCase():"toUpperCase"===a.kind?e.data=e.data.toUpperCase():"startsWith"===a.kind?e.data.startsWith(a.value)||(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.invalid_string,validation:{startsWith:a.value},message:a.message}),r.dirty()):"endsWith"===a.kind?e.data.endsWith(a.value)||(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.invalid_string,validation:{endsWith:a.value},message:a.message}),r.dirty()):"datetime"===a.kind?kKe(a).test(e.data)||(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.invalid_string,validation:"datetime",message:a.message}),r.dirty()):"ip"===a.kind?SKe(e.data,a.version)||(s=this._getOrReturnCtx(e,s),bn(s,{validation:"ip",code:sn.invalid_string,message:a.message}),r.dirty()):Zi.assertNever(a);return{status:r.value,value:e.data}}_regex(e,i,r){return this.refinement(s=>e.test(s),{validation:i,code:sn.invalid_string,...Fn.errToObj(r)})}_addCheck(e){return new t({...this._def,checks:[...this._def.checks,e]})}email(e){return this._addCheck({kind:"email",...Fn.errToObj(e)})}url(e){return this._addCheck({kind:"url",...Fn.errToObj(e)})}emoji(e){return this._addCheck({kind:"emoji",...Fn.errToObj(e)})}uuid(e){return this._addCheck({kind:"uuid",...Fn.errToObj(e)})}cuid(e){return this._addCheck({kind:"cuid",...Fn.errToObj(e)})}cuid2(e){return this._addCheck({kind:"cuid2",...Fn.errToObj(e)})}ulid(e){return this._addCheck({kind:"ulid",...Fn.errToObj(e)})}ip(e){return this._addCheck({kind:"ip",...Fn.errToObj(e)})}datetime(e){var i;return this._addCheck("string"==typeof e?{kind:"datetime",precision:null,offset:!1,message:e}:{kind:"datetime",precision:typeof e?.precision>"u"?null:e?.precision,offset:null!==(i=e?.offset)&&void 0!==i&&i,...Fn.errToObj(e?.message)})}regex(e,i){return this._addCheck({kind:"regex",regex:e,...Fn.errToObj(i)})}includes(e,i){return this._addCheck({kind:"includes",value:e,position:i?.position,...Fn.errToObj(i?.message)})}startsWith(e,i){return this._addCheck({kind:"startsWith",value:e,...Fn.errToObj(i)})}endsWith(e,i){return this._addCheck({kind:"endsWith",value:e,...Fn.errToObj(i)})}min(e,i){return this._addCheck({kind:"min",value:e,...Fn.errToObj(i)})}max(e,i){return this._addCheck({kind:"max",value:e,...Fn.errToObj(i)})}length(e,i){return this._addCheck({kind:"length",value:e,...Fn.errToObj(i)})}nonempty(e){return this.min(1,Fn.errToObj(e))}trim(){return new t({...this._def,checks:[...this._def.checks,{kind:"trim"}]})}toLowerCase(){return new t({...this._def,checks:[...this._def.checks,{kind:"toLowerCase"}]})}toUpperCase(){return new t({...this._def,checks:[...this._def.checks,{kind:"toUpperCase"}]})}get isDatetime(){return!!this._def.checks.find(e=>"datetime"===e.kind)}get isEmail(){return!!this._def.checks.find(e=>"email"===e.kind)}get isURL(){return!!this._def.checks.find(e=>"url"===e.kind)}get isEmoji(){return!!this._def.checks.find(e=>"emoji"===e.kind)}get isUUID(){return!!this._def.checks.find(e=>"uuid"===e.kind)}get isCUID(){return!!this._def.checks.find(e=>"cuid"===e.kind)}get isCUID2(){return!!this._def.checks.find(e=>"cuid2"===e.kind)}get isULID(){return!!this._def.checks.find(e=>"ulid"===e.kind)}get isIP(){return!!this._def.checks.find(e=>"ip"===e.kind)}get minLength(){let e=null;for(const i of this._def.checks)"min"===i.kind&&(null===e||i.value>e)&&(e=i.value);return e}get maxLength(){let e=null;for(const i of this._def.checks)"max"===i.kind&&(null===e||i.value<e)&&(e=i.value);return e}}return t.create=n=>{var e;return new t({checks:[],typeName:Jn.ZodString,coerce:null!==(e=n?.coerce)&&void 0!==e&&e,...gi(n)})},t})();function EKe(t,n){const e=(t.toString().split(".")[1]||"").length,i=(n.toString().split(".")[1]||"").length,r=e>i?e:i;return parseInt(t.toFixed(r).replace(".",""))%parseInt(n.toFixed(r).replace(".",""))/Math.pow(10,r)}let xA=(()=>{class t extends wi{constructor(){super(...arguments),this.min=this.gte,this.max=this.lte,this.step=this.multipleOf}_parse(e){if(this._def.coerce&&(e.data=Number(e.data)),this._getType(e)!==yn.number){const a=this._getOrReturnCtx(e);return bn(a,{code:sn.invalid_type,expected:yn.number,received:a.parsedType}),hi}let r;const s=new Va;for(const a of this._def.checks)"int"===a.kind?Zi.isInteger(e.data)||(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.invalid_type,expected:"integer",received:"float",message:a.message}),s.dirty()):"min"===a.kind?(a.inclusive?e.data<a.value:e.data<=a.value)&&(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.too_small,minimum:a.value,type:"number",inclusive:a.inclusive,exact:!1,message:a.message}),s.dirty()):"max"===a.kind?(a.inclusive?e.data>a.value:e.data>=a.value)&&(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.too_big,maximum:a.value,type:"number",inclusive:a.inclusive,exact:!1,message:a.message}),s.dirty()):"multipleOf"===a.kind?0!==EKe(e.data,a.value)&&(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.not_multiple_of,multipleOf:a.value,message:a.message}),s.dirty()):"finite"===a.kind?Number.isFinite(e.data)||(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.not_finite,message:a.message}),s.dirty()):Zi.assertNever(a);return{status:s.value,value:e.data}}gte(e,i){return this.setLimit("min",e,!0,Fn.toString(i))}gt(e,i){return this.setLimit("min",e,!1,Fn.toString(i))}lte(e,i){return this.setLimit("max",e,!0,Fn.toString(i))}lt(e,i){return this.setLimit("max",e,!1,Fn.toString(i))}setLimit(e,i,r,s){return new t({...this._def,checks:[...this._def.checks,{kind:e,value:i,inclusive:r,message:Fn.toString(s)}]})}_addCheck(e){return new t({...this._def,checks:[...this._def.checks,e]})}int(e){return this._addCheck({kind:"int",message:Fn.toString(e)})}positive(e){return this._addCheck({kind:"min",value:0,inclusive:!1,message:Fn.toString(e)})}negative(e){return this._addCheck({kind:"max",value:0,inclusive:!1,message:Fn.toString(e)})}nonpositive(e){return this._addCheck({kind:"max",value:0,inclusive:!0,message:Fn.toString(e)})}nonnegative(e){return this._addCheck({kind:"min",value:0,inclusive:!0,message:Fn.toString(e)})}multipleOf(e,i){return this._addCheck({kind:"multipleOf",value:e,message:Fn.toString(i)})}finite(e){return this._addCheck({kind:"finite",message:Fn.toString(e)})}safe(e){return this._addCheck({kind:"min",inclusive:!0,value:Number.MIN_SAFE_INTEGER,message:Fn.toString(e)})._addCheck({kind:"max",inclusive:!0,value:Number.MAX_SAFE_INTEGER,message:Fn.toString(e)})}get minValue(){let e=null;for(const i of this._def.checks)"min"===i.kind&&(null===e||i.value>e)&&(e=i.value);return e}get maxValue(){let e=null;for(const i of this._def.checks)"max"===i.kind&&(null===e||i.value<e)&&(e=i.value);return e}get isInt(){return!!this._def.checks.find(e=>"int"===e.kind||"multipleOf"===e.kind&&Zi.isInteger(e.value))}get isFinite(){let e=null,i=null;for(const r of this._def.checks){if("finite"===r.kind||"int"===r.kind||"multipleOf"===r.kind)return!0;"min"===r.kind?(null===i||r.value>i)&&(i=r.value):"max"===r.kind&&(null===e||r.value<e)&&(e=r.value)}return Number.isFinite(i)&&Number.isFinite(e)}}return t.create=n=>new t({checks:[],typeName:Jn.ZodNumber,coerce:n?.coerce||!1,...gi(n)}),t})(),TA=(()=>{class t extends wi{constructor(){super(...arguments),this.min=this.gte,this.max=this.lte}_parse(e){if(this._def.coerce&&(e.data=BigInt(e.data)),this._getType(e)!==yn.bigint){const a=this._getOrReturnCtx(e);return bn(a,{code:sn.invalid_type,expected:yn.bigint,received:a.parsedType}),hi}let r;const s=new Va;for(const a of this._def.checks)"min"===a.kind?(a.inclusive?e.data<a.value:e.data<=a.value)&&(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.too_small,type:"bigint",minimum:a.value,inclusive:a.inclusive,message:a.message}),s.dirty()):"max"===a.kind?(a.inclusive?e.data>a.value:e.data>=a.value)&&(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.too_big,type:"bigint",maximum:a.value,inclusive:a.inclusive,message:a.message}),s.dirty()):"multipleOf"===a.kind?e.data%a.value!==BigInt(0)&&(r=this._getOrReturnCtx(e,r),bn(r,{code:sn.not_multiple_of,multipleOf:a.value,message:a.message}),s.dirty()):Zi.assertNever(a);return{status:s.value,value:e.data}}gte(e,i){return this.setLimit("min",e,!0,Fn.toString(i))}gt(e,i){return this.setLimit("min",e,!1,Fn.toString(i))}lte(e,i){return this.setLimit("max",e,!0,Fn.toString(i))}lt(e,i){return this.setLimit("max",e,!1,Fn.toString(i))}setLimit(e,i,r,s){return new t({...this._def,checks:[...this._def.checks,{kind:e,value:i,inclusive:r,message:Fn.toString(s)}]})}_addCheck(e){return new t({...this._def,checks:[...this._def.checks,e]})}positive(e){return this._addCheck({kind:"min",value:BigInt(0),inclusive:!1,message:Fn.toString(e)})}negative(e){return this._addCheck({kind:"max",value:BigInt(0),inclusive:!1,message:Fn.toString(e)})}nonpositive(e){return this._addCheck({kind:"max",value:BigInt(0),inclusive:!0,message:Fn.toString(e)})}nonnegative(e){return this._addCheck({kind:"min",value:BigInt(0),inclusive:!0,message:Fn.toString(e)})}multipleOf(e,i){return this._addCheck({kind:"multipleOf",value:e,message:Fn.toString(i)})}get minValue(){let e=null;for(const i of this._def.checks)"min"===i.kind&&(null===e||i.value>e)&&(e=i.value);return e}get maxValue(){let e=null;for(const i of this._def.checks)"max"===i.kind&&(null===e||i.value<e)&&(e=i.value);return e}}return t.create=n=>{var e;return new t({checks:[],typeName:Jn.ZodBigInt,coerce:null!==(e=n?.coerce)&&void 0!==e&&e,...gi(n)})},t})(),MA=(()=>{class t extends wi{_parse(e){if(this._def.coerce&&(e.data=!!e.data),this._getType(e)!==yn.boolean){const r=this._getOrReturnCtx(e);return bn(r,{code:sn.invalid_type,expected:yn.boolean,received:r.parsedType}),hi}return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodBoolean,coerce:n?.coerce||!1,...gi(n)}),t})(),kA=(()=>{class t extends wi{_parse(e){if(this._def.coerce&&(e.data=new Date(e.data)),this._getType(e)!==yn.date){const a=this._getOrReturnCtx(e);return bn(a,{code:sn.invalid_type,expected:yn.date,received:a.parsedType}),hi}if(isNaN(e.data.getTime()))return bn(this._getOrReturnCtx(e),{code:sn.invalid_date}),hi;const r=new Va;let s;for(const a of this._def.checks)"min"===a.kind?e.data.getTime()<a.value&&(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.too_small,message:a.message,inclusive:!0,exact:!1,minimum:a.value,type:"date"}),r.dirty()):"max"===a.kind?e.data.getTime()>a.value&&(s=this._getOrReturnCtx(e,s),bn(s,{code:sn.too_big,message:a.message,inclusive:!0,exact:!1,maximum:a.value,type:"date"}),r.dirty()):Zi.assertNever(a);return{status:r.value,value:new Date(e.data.getTime())}}_addCheck(e){return new t({...this._def,checks:[...this._def.checks,e]})}min(e,i){return this._addCheck({kind:"min",value:e.getTime(),message:Fn.toString(i)})}max(e,i){return this._addCheck({kind:"max",value:e.getTime(),message:Fn.toString(i)})}get minDate(){let e=null;for(const i of this._def.checks)"min"===i.kind&&(null===e||i.value>e)&&(e=i.value);return null!=e?new Date(e):null}get maxDate(){let e=null;for(const i of this._def.checks)"max"===i.kind&&(null===e||i.value<e)&&(e=i.value);return null!=e?new Date(e):null}}return t.create=n=>new t({checks:[],coerce:n?.coerce||!1,typeName:Jn.ZodDate,...gi(n)}),t})(),cee=(()=>{class t extends wi{_parse(e){if(this._getType(e)!==yn.symbol){const r=this._getOrReturnCtx(e);return bn(r,{code:sn.invalid_type,expected:yn.symbol,received:r.parsedType}),hi}return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodSymbol,...gi(n)}),t})(),SA=(()=>{class t extends wi{_parse(e){if(this._getType(e)!==yn.undefined){const r=this._getOrReturnCtx(e);return bn(r,{code:sn.invalid_type,expected:yn.undefined,received:r.parsedType}),hi}return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodUndefined,...gi(n)}),t})(),EA=(()=>{class t extends wi{_parse(e){if(this._getType(e)!==yn.null){const r=this._getOrReturnCtx(e);return bn(r,{code:sn.invalid_type,expected:yn.null,received:r.parsedType}),hi}return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodNull,...gi(n)}),t})(),ty=(()=>{class t extends wi{constructor(){super(...arguments),this._any=!0}_parse(e){return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodAny,...gi(n)}),t})(),Ih=(()=>{class t extends wi{constructor(){super(...arguments),this._unknown=!0}_parse(e){return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodUnknown,...gi(n)}),t})(),q4=(()=>{class t extends wi{_parse(e){const i=this._getOrReturnCtx(e);return bn(i,{code:sn.invalid_type,expected:yn.never,received:i.parsedType}),hi}}return t.create=n=>new t({typeName:Jn.ZodNever,...gi(n)}),t})(),lee=(()=>{class t extends wi{_parse(e){if(this._getType(e)!==yn.undefined){const r=this._getOrReturnCtx(e);return bn(r,{code:sn.invalid_type,expected:yn.void,received:r.parsedType}),hi}return fo(e.data)}}return t.create=n=>new t({typeName:Jn.ZodVoid,...gi(n)}),t})(),Dh=(()=>{class t extends wi{_parse(e){const{ctx:i,status:r}=this._processInputParams(e),s=this._def;if(i.parsedType!==yn.array)return bn(i,{code:sn.invalid_type,expected:yn.array,received:i.parsedType}),hi;if(null!==s.exactLength){const o=i.data.length>s.exactLength.value,c=i.data.length<s.exactLength.value;(o||c)&&(bn(i,{code:o?sn.too_big:sn.too_small,minimum:c?s.exactLength.value:void 0,maximum:o?s.exactLength.value:void 0,type:"array",inclusive:!0,exact:!0,message:s.exactLength.message}),r.dirty())}if(null!==s.minLength&&i.data.length<s.minLength.value&&(bn(i,{code:sn.too_small,minimum:s.minLength.value,type:"array",inclusive:!0,exact:!1,message:s.minLength.message}),r.dirty()),null!==s.maxLength&&i.data.length>s.maxLength.value&&(bn(i,{code:sn.too_big,maximum:s.maxLength.value,type:"array",inclusive:!0,exact:!1,message:s.maxLength.message}),r.dirty()),i.common.async)return Promise.all([...i.data].map((o,c)=>s.type._parseAsync(new Ic(i,o,i.path,c)))).then(o=>Va.mergeArray(r,o));const a=[...i.data].map((o,c)=>s.type._parseSync(new Ic(i,o,i.path,c)));return Va.mergeArray(r,a)}get element(){return this._def.type}min(e,i){return new t({...this._def,minLength:{value:e,message:Fn.toString(i)}})}max(e,i){return new t({...this._def,maxLength:{value:e,message:Fn.toString(i)}})}length(e,i){return new t({...this._def,exactLength:{value:e,message:Fn.toString(i)}})}nonempty(e){return this.min(1,e)}}return t.create=(n,e)=>new t({type:n,minLength:null,maxLength:null,exactLength:null,typeName:Jn.ZodArray,...gi(e)}),t})();function Sd(t){if(t instanceof Ed){const n={};for(const e in t.shape)n[e]=Z4.create(Sd(t.shape[e]));return new Ed({...t._def,shape:()=>n})}return t instanceof Dh?new Dh({...t._def,type:Sd(t.element)}):t instanceof Z4?Z4.create(Sd(t.unwrap())):t instanceof Rh?Rh.create(Sd(t.unwrap())):t instanceof Ad?Ad.create(t.items.map(n=>Sd(n))):t}let Ed=(()=>{class t extends wi{constructor(){super(...arguments),this._cached=null,this.nonstrict=this.passthrough,this.augment=this.extend}_getCached(){if(null!==this._cached)return this._cached;const e=this._def.shape(),i=Zi.objectKeys(e);return this._cached={shape:e,keys:i}}_parse(e){if(this._getType(e)!==yn.object){const u=this._getOrReturnCtx(e);return bn(u,{code:sn.invalid_type,expected:yn.object,received:u.parsedType}),hi}const{status:r,ctx:s}=this._processInputParams(e),{shape:a,keys:o}=this._getCached(),c=[];if(!(this._def.catchall instanceof q4&&"strip"===this._def.unknownKeys))for(const u in s.data)o.includes(u)||c.push(u);const l=[];for(const u of o)l.push({key:{status:"valid",value:u},value:a[u]._parse(new Ic(s,s.data[u],s.path,u)),alwaysSet:u in s.data});if(this._def.catchall instanceof q4){const u=this._def.unknownKeys;if("passthrough"===u)for(const d of c)l.push({key:{status:"valid",value:d},value:{status:"valid",value:s.data[d]}});else if("strict"===u)c.length>0&&(bn(s,{code:sn.unrecognized_keys,keys:c}),r.dirty());else if("strip"!==u)throw new Error("Internal ZodObject error: invalid unknownKeys value.")}else{const u=this._def.catchall;for(const d of c)l.push({key:{status:"valid",value:d},value:u._parse(new Ic(s,s.data[d],s.path,d)),alwaysSet:d in s.data})}return s.common.async?Promise.resolve().then((0,Ge.Z)(function*(){const u=[];for(const d of l){const h=yield d.key;u.push({key:h,value:yield d.value,alwaysSet:d.alwaysSet})}return u})).then(u=>Va.mergeObjectSync(r,u)):Va.mergeObjectSync(r,l)}get shape(){return this._def.shape()}strict(e){return new t({...this._def,unknownKeys:"strict",...void 0!==e?{errorMap:(i,r)=>{var s,a,o,c;const l=null!==(o=null===(a=(s=this._def).errorMap)||void 0===a?void 0:a.call(s,i,r).message)&&void 0!==o?o:r.defaultError;return"unrecognized_keys"===i.code?{message:null!==(c=Fn.errToObj(e).message)&&void 0!==c?c:l}:{message:l}}}:{}})}strip(){return new t({...this._def,unknownKeys:"strip"})}passthrough(){return new t({...this._def,unknownKeys:"passthrough"})}extend(e){return new t({...this._def,shape:()=>({...this._def.shape(),...e})})}merge(e){return new t({unknownKeys:e._def.unknownKeys,catchall:e._def.catchall,shape:()=>({...this._def.shape(),...e._def.shape()}),typeName:Jn.ZodObject})}setKey(e,i){return this.augment({[e]:i})}catchall(e){return new t({...this._def,catchall:e})}pick(e){const i={};return Zi.objectKeys(e).forEach(r=>{e[r]&&this.shape[r]&&(i[r]=this.shape[r])}),new t({...this._def,shape:()=>i})}omit(e){const i={};return Zi.objectKeys(this.shape).forEach(r=>{e[r]||(i[r]=this.shape[r])}),new t({...this._def,shape:()=>i})}deepPartial(){return Sd(this)}partial(e){const i={};return Zi.objectKeys(this.shape).forEach(r=>{const s=this.shape[r];i[r]=e&&!e[r]?s:s.optional()}),new t({...this._def,shape:()=>i})}required(e){const i={};return Zi.objectKeys(this.shape).forEach(r=>{if(e&&!e[r])i[r]=this.shape[r];else{let a=this.shape[r];for(;a instanceof Z4;)a=a._def.innerType;i[r]=a}}),new t({...this._def,shape:()=>i})}keyof(){return fee(Zi.objectKeys(this.shape))}}return t.create=(n,e)=>new t({shape:()=>n,unknownKeys:"strip",catchall:q4.create(),typeName:Jn.ZodObject,...gi(e)}),t.strictCreate=(n,e)=>new t({shape:()=>n,unknownKeys:"strict",catchall:q4.create(),typeName:Jn.ZodObject,...gi(e)}),t.lazycreate=(n,e)=>new t({shape:n,unknownKeys:"strip",catchall:q4.create(),typeName:Jn.ZodObject,...gi(e)}),t})(),AA=(()=>{class t extends wi{_parse(e){const{ctx:i}=this._processInputParams(e),r=this._def.options;if(i.common.async)return Promise.all(r.map(function(){var a=(0,Ge.Z)(function*(o){const c={...i,common:{...i.common,issues:[]},parent:null};return{result:yield o._parseAsync({data:i.data,path:i.path,parent:c}),ctx:c}});return function(o){return a.apply(this,arguments)}}())).then(function s(a){for(const c of a)if("valid"===c.result.status)return c.result;for(const c of a)if("dirty"===c.result.status)return i.common.issues.push(...c.ctx.common.issues),c.result;const o=a.map(c=>new Nl(c.ctx.common.issues));return bn(i,{code:sn.invalid_union,unionErrors:o}),hi});{let a;const o=[];for(const l of r){const u={...i,common:{...i.common,issues:[]},parent:null},d=l._parseSync({data:i.data,path:i.path,parent:u});if("valid"===d.status)return d;"dirty"===d.status&&!a&&(a={result:d,ctx:u}),u.common.issues.length&&o.push(u.common.issues)}if(a)return i.common.issues.push(...a.ctx.common.issues),a.result;const c=o.map(l=>new Nl(l));return bn(i,{code:sn.invalid_union,unionErrors:c}),hi}}get options(){return this._def.options}}return t.create=(n,e)=>new t({options:n,typeName:Jn.ZodUnion,...gi(e)}),t})();const ny=t=>t instanceof NA?ny(t.schema):t instanceof G4?ny(t.innerType()):t instanceof RA?[t.value]:t instanceof ry?t.options:t instanceof LA?Object.keys(t.enum):t instanceof PA?ny(t._def.innerType):t instanceof SA?[void 0]:t instanceof EA?[null]:null;class iy extends wi{_parse(n){const{ctx:e}=this._processInputParams(n);if(e.parsedType!==yn.object)return bn(e,{code:sn.invalid_type,expected:yn.object,received:e.parsedType}),hi;const i=this.discriminator,s=this.optionsMap.get(e.data[i]);return s?e.common.async?s._parseAsync({data:e.data,path:e.path,parent:e}):s._parseSync({data:e.data,path:e.path,parent:e}):(bn(e,{code:sn.invalid_union_discriminator,options:Array.from(this.optionsMap.keys()),path:[i]}),hi)}get discriminator(){return this._def.discriminator}get options(){return this._def.options}get optionsMap(){return this._def.optionsMap}static create(n,e,i){const r=new Map;for(const s of e){const a=ny(s.shape[n]);if(!a)throw new Error(`A discriminator value for key \`${n}\` could not be extracted from all schema options`);for(const o of a){if(r.has(o))throw new Error(`Discriminator property ${String(n)} has duplicate value ${String(o)}`);r.set(o,s)}}return new iy({typeName:Jn.ZodDiscriminatedUnion,discriminator:n,options:e,optionsMap:r,...gi(i)})}}function IA(t,n){const e=J3(t),i=J3(n);if(t===n)return{valid:!0,data:t};if(e===yn.object&&i===yn.object){const r=Zi.objectKeys(n),s=Zi.objectKeys(t).filter(o=>-1!==r.indexOf(o)),a={...t,...n};for(const o of s){const c=IA(t[o],n[o]);if(!c.valid)return{valid:!1};a[o]=c.data}return{valid:!0,data:a}}if(e===yn.array&&i===yn.array){if(t.length!==n.length)return{valid:!1};const r=[];for(let s=0;s<t.length;s++){const c=IA(t[s],n[s]);if(!c.valid)return{valid:!1};r.push(c.data)}return{valid:!0,data:r}}return e===yn.date&&i===yn.date&&+t==+n?{valid:!0,data:t}:{valid:!1}}let DA=(()=>{class t extends wi{_parse(e){const{status:i,ctx:r}=this._processInputParams(e),s=(a,o)=>{if(bA(a)||bA(o))return hi;const c=IA(a.value,o.value);return c.valid?((wA(a)||wA(o))&&i.dirty(),{status:i.value,value:c.data}):(bn(r,{code:sn.invalid_intersection_types}),hi)};return r.common.async?Promise.all([this._def.left._parseAsync({data:r.data,path:r.path,parent:r}),this._def.right._parseAsync({data:r.data,path:r.path,parent:r})]).then(([a,o])=>s(a,o)):s(this._def.left._parseSync({data:r.data,path:r.path,parent:r}),this._def.right._parseSync({data:r.data,path:r.path,parent:r}))}}return t.create=(n,e,i)=>new t({left:n,right:e,typeName:Jn.ZodIntersection,...gi(i)}),t})(),Ad=(()=>{class t extends wi{_parse(e){const{status:i,ctx:r}=this._processInputParams(e);if(r.parsedType!==yn.array)return bn(r,{code:sn.invalid_type,expected:yn.array,received:r.parsedType}),hi;if(r.data.length<this._def.items.length)return bn(r,{code:sn.too_small,minimum:this._def.items.length,inclusive:!0,exact:!1,type:"array"}),hi;!this._def.rest&&r.data.length>this._def.items.length&&(bn(r,{code:sn.too_big,maximum:this._def.items.length,inclusive:!0,exact:!1,type:"array"}),i.dirty());const a=[...r.data].map((o,c)=>{const l=this._def.items[c]||this._def.rest;return l?l._parse(new Ic(r,o,r.path,c)):null}).filter(o=>!!o);return r.common.async?Promise.all(a).then(o=>Va.mergeArray(i,o)):Va.mergeArray(i,a)}get items(){return this._def.items}rest(e){return new t({...this._def,rest:e})}}return t.create=(n,e)=>{if(!Array.isArray(n))throw new Error("You must pass an array of schemas to z.tuple([ ... ])");return new t({items:n,typeName:Jn.ZodTuple,rest:null,...gi(e)})},t})();class Nh extends wi{get keySchema(){return this._def.keyType}get valueSchema(){return this._def.valueType}_parse(n){const{status:e,ctx:i}=this._processInputParams(n);if(i.parsedType!==yn.object)return bn(i,{code:sn.invalid_type,expected:yn.object,received:i.parsedType}),hi;const r=[],s=this._def.keyType,a=this._def.valueType;for(const o in i.data)r.push({key:s._parse(new Ic(i,o,i.path,o)),value:a._parse(new Ic(i,i.data[o],i.path,o))});return i.common.async?Va.mergeObjectAsync(e,r):Va.mergeObjectSync(e,r)}get element(){return this._def.valueType}static create(n,e,i){return new Nh(e instanceof wi?{keyType:n,valueType:e,typeName:Jn.ZodRecord,...gi(i)}:{keyType:ey.create(),valueType:n,typeName:Jn.ZodRecord,...gi(e)})}}let uee=(()=>{class t extends wi{get keySchema(){return this._def.keyType}get valueSchema(){return this._def.valueType}_parse(e){const{status:i,ctx:r}=this._processInputParams(e);if(r.parsedType!==yn.map)return bn(r,{code:sn.invalid_type,expected:yn.map,received:r.parsedType}),hi;const s=this._def.keyType,a=this._def.valueType,o=[...r.data.entries()].map(([c,l],u)=>({key:s._parse(new Ic(r,c,r.path,[u,"key"])),value:a._parse(new Ic(r,l,r.path,[u,"value"]))}));if(r.common.async){const c=new Map;return Promise.resolve().then((0,Ge.Z)(function*(){for(const l of o){const u=yield l.key,d=yield l.value;if("aborted"===u.status||"aborted"===d.status)return hi;("dirty"===u.status||"dirty"===d.status)&&i.dirty(),c.set(u.value,d.value)}return{status:i.value,value:c}}))}{const c=new Map;for(const l of o){const u=l.key,d=l.value;if("aborted"===u.status||"aborted"===d.status)return hi;("dirty"===u.status||"dirty"===d.status)&&i.dirty(),c.set(u.value,d.value)}return{status:i.value,value:c}}}}return t.create=(n,e,i)=>new t({valueType:e,keyType:n,typeName:Jn.ZodMap,...gi(i)}),t})(),dee=(()=>{class t extends wi{_parse(e){const{status:i,ctx:r}=this._processInputParams(e);if(r.parsedType!==yn.set)return bn(r,{code:sn.invalid_type,expected:yn.set,received:r.parsedType}),hi;const s=this._def;null!==s.minSize&&r.data.size<s.minSize.value&&(bn(r,{code:sn.too_small,minimum:s.minSize.value,type:"set",inclusive:!0,exact:!1,message:s.minSize.message}),i.dirty()),null!==s.maxSize&&r.data.size>s.maxSize.value&&(bn(r,{code:sn.too_big,maximum:s.maxSize.value,type:"set",inclusive:!0,exact:!1,message:s.maxSize.message}),i.dirty());const a=this._def.valueType;function o(l){const u=new Set;for(const d of l){if("aborted"===d.status)return hi;"dirty"===d.status&&i.dirty(),u.add(d.value)}return{status:i.value,value:u}}const c=[...r.data.values()].map((l,u)=>a._parse(new Ic(r,l,r.path,u)));return r.common.async?Promise.all(c).then(l=>o(l)):o(c)}min(e,i){return new t({...this._def,minSize:{value:e,message:Fn.toString(i)}})}max(e,i){return new t({...this._def,maxSize:{value:e,message:Fn.toString(i)}})}size(e,i){return this.min(e,i).max(e,i)}nonempty(e){return this.min(1,e)}}return t.create=(n,e)=>new t({valueType:n,minSize:null,maxSize:null,typeName:Jn.ZodSet,...gi(e)}),t})();class Id extends wi{constructor(){super(...arguments),this.validate=this.implement}_parse(n){const{ctx:e}=this._processInputParams(n);if(e.parsedType!==yn.function)return bn(e,{code:sn.invalid_type,expected:yn.function,received:e.parsedType}),hi;function i(o,c){return Qv({data:o,path:e.path,errorMaps:[e.common.contextualErrorMap,e.schemaErrorMap,Xv(),Eh].filter(l=>!!l),issueData:{code:sn.invalid_arguments,argumentsError:c}})}function r(o,c){return Qv({data:o,path:e.path,errorMaps:[e.common.contextualErrorMap,e.schemaErrorMap,Xv(),Eh].filter(l=>!!l),issueData:{code:sn.invalid_return_type,returnTypeError:c}})}const s={errorMap:e.common.contextualErrorMap},a=e.data;if(this._def.returns instanceof sy){const o=this;return fo((0,Ge.Z)(function*(...c){const l=new Nl([]),u=yield o._def.args.parseAsync(c,s).catch(y=>{throw l.addIssue(i(c,y)),l}),d=yield Reflect.apply(a,this,u);return yield o._def.returns._def.type.parseAsync(d,s).catch(y=>{throw l.addIssue(r(d,y)),l})}))}{const o=this;return fo(function(...c){const l=o._def.args.safeParse(c,s);if(!l.success)throw new Nl([i(c,l.error)]);const u=Reflect.apply(a,this,l.data),d=o._def.returns.safeParse(u,s);if(!d.success)throw new Nl([r(u,d.error)]);return d.data})}}parameters(){return this._def.args}returnType(){return this._def.returns}args(...n){return new Id({...this._def,args:Ad.create(n).rest(Ih.create())})}returns(n){return new Id({...this._def,returns:n})}implement(n){return this.parse(n)}strictImplement(n){return this.parse(n)}static create(n,e,i){return new Id({args:n||Ad.create([]).rest(Ih.create()),returns:e||Ih.create(),typeName:Jn.ZodFunction,...gi(i)})}}let NA=(()=>{class t extends wi{get schema(){return this._def.getter()}_parse(e){const{ctx:i}=this._processInputParams(e);return this._def.getter()._parse({data:i.data,path:i.path,parent:i})}}return t.create=(n,e)=>new t({getter:n,typeName:Jn.ZodLazy,...gi(e)}),t})(),RA=(()=>{class t extends wi{_parse(e){if(e.data!==this._def.value){const i=this._getOrReturnCtx(e);return bn(i,{received:i.data,code:sn.invalid_literal,expected:this._def.value}),hi}return{status:"valid",value:e.data}}get value(){return this._def.value}}return t.create=(n,e)=>new t({value:n,typeName:Jn.ZodLiteral,...gi(e)}),t})();function fee(t,n){return new ry({values:t,typeName:Jn.ZodEnum,...gi(n)})}let ry=(()=>{class t extends wi{_parse(e){if("string"!=typeof e.data){const i=this._getOrReturnCtx(e);return bn(i,{expected:Zi.joinValues(this._def.values),received:i.parsedType,code:sn.invalid_type}),hi}if(-1===this._def.values.indexOf(e.data)){const i=this._getOrReturnCtx(e);return bn(i,{received:i.data,code:sn.invalid_enum_value,options:this._def.values}),hi}return fo(e.data)}get options(){return this._def.values}get enum(){const e={};for(const i of this._def.values)e[i]=i;return e}get Values(){const e={};for(const i of this._def.values)e[i]=i;return e}get Enum(){const e={};for(const i of this._def.values)e[i]=i;return e}extract(e){return t.create(e)}exclude(e){return t.create(this.options.filter(i=>!e.includes(i)))}}return t.create=fee,t})(),LA=(()=>{class t extends wi{_parse(e){const i=Zi.getValidEnumValues(this._def.values),r=this._getOrReturnCtx(e);if(r.parsedType!==yn.string&&r.parsedType!==yn.number){const s=Zi.objectValues(i);return bn(r,{expected:Zi.joinValues(s),received:r.parsedType,code:sn.invalid_type}),hi}if(-1===i.indexOf(e.data)){const s=Zi.objectValues(i);return bn(r,{received:r.data,code:sn.invalid_enum_value,options:s}),hi}return fo(e.data)}get enum(){return this._def.values}}return t.create=(n,e)=>new t({values:n,typeName:Jn.ZodNativeEnum,...gi(e)}),t})(),sy=(()=>{class t extends wi{unwrap(){return this._def.type}_parse(e){const{ctx:i}=this._processInputParams(e);if(i.parsedType!==yn.promise&&!1===i.common.async)return bn(i,{code:sn.invalid_type,expected:yn.promise,received:i.parsedType}),hi;const r=i.parsedType===yn.promise?i.data:Promise.resolve(i.data);return fo(r.then(s=>this._def.type.parseAsync(s,{path:i.path,errorMap:i.common.contextualErrorMap})))}}return t.create=(n,e)=>new t({type:n,typeName:Jn.ZodPromise,...gi(e)}),t})(),G4=(()=>{class t extends wi{innerType(){return this._def.schema}sourceType(){return this._def.schema._def.typeName===Jn.ZodEffects?this._def.schema.sourceType():this._def.schema}_parse(e){const{status:i,ctx:r}=this._processInputParams(e),s=this._def.effect||null,a={addIssue:o=>{bn(r,o),o.fatal?i.abort():i.dirty()},get path(){return r.path}};if(a.addIssue=a.addIssue.bind(a),"preprocess"===s.type){const o=s.transform(r.data,a);return r.common.issues.length?{status:"dirty",value:r.data}:r.common.async?Promise.resolve(o).then(c=>this._def.schema._parseAsync({data:c,path:r.path,parent:r})):this._def.schema._parseSync({data:o,path:r.path,parent:r})}if("refinement"===s.type){const o=c=>{const l=s.refinement(c,a);if(r.common.async)return Promise.resolve(l);if(l instanceof Promise)throw new Error("Async refinement encountered during synchronous parse operation. Use .parseAsync instead.");return c};if(!1===r.common.async){const c=this._def.schema._parseSync({data:r.data,path:r.path,parent:r});return"aborted"===c.status?hi:("dirty"===c.status&&i.dirty(),o(c.value),{status:i.value,value:c.value})}return this._def.schema._parseAsync({data:r.data,path:r.path,parent:r}).then(c=>"aborted"===c.status?hi:("dirty"===c.status&&i.dirty(),o(c.value).then(()=>({status:i.value,value:c.value}))))}if("transform"===s.type){if(!1===r.common.async){const o=this._def.schema._parseSync({data:r.data,path:r.path,parent:r});if(!Ah(o))return o;const c=s.transform(o.value,a);if(c instanceof Promise)throw new Error("Asynchronous transform encountered during synchronous parse operation. Use .parseAsync instead.");return{status:i.value,value:c}}return this._def.schema._parseAsync({data:r.data,path:r.path,parent:r}).then(o=>Ah(o)?Promise.resolve(s.transform(o.value,a)).then(c=>({status:i.value,value:c})):o)}Zi.assertNever(s)}}return t.create=(n,e,i)=>new t({schema:n,typeName:Jn.ZodEffects,effect:e,...gi(i)}),t.createWithPreprocess=(n,e,i)=>new t({schema:e,effect:{type:"preprocess",transform:n},typeName:Jn.ZodEffects,...gi(i)}),t})(),Z4=(()=>{class t extends wi{_parse(e){return this._getType(e)===yn.undefined?fo(void 0):this._def.innerType._parse(e)}unwrap(){return this._def.innerType}}return t.create=(n,e)=>new t({innerType:n,typeName:Jn.ZodOptional,...gi(e)}),t})(),Rh=(()=>{class t extends wi{_parse(e){return this._getType(e)===yn.null?fo(null):this._def.innerType._parse(e)}unwrap(){return this._def.innerType}}return t.create=(n,e)=>new t({innerType:n,typeName:Jn.ZodNullable,...gi(e)}),t})(),PA=(()=>{class t extends wi{_parse(e){const{ctx:i}=this._processInputParams(e);let r=i.data;return i.parsedType===yn.undefined&&(r=this._def.defaultValue()),this._def.innerType._parse({data:r,path:i.path,parent:i})}removeDefault(){return this._def.innerType}}return t.create=(n,e)=>new t({innerType:n,typeName:Jn.ZodDefault,defaultValue:"function"==typeof e.default?e.default:()=>e.default,...gi(e)}),t})(),hee=(()=>{class t extends wi{_parse(e){const{ctx:i}=this._processInputParams(e),r={...i,common:{...i.common,issues:[]}},s=this._def.innerType._parse({data:r.data,path:r.path,parent:{...r}});return Jv(s)?s.then(a=>({status:"valid",value:"valid"===a.status?a.value:this._def.catchValue({get error(){return new Nl(r.common.issues)},input:r.data})})):{status:"valid",value:"valid"===s.status?s.value:this._def.catchValue({get error(){return new Nl(r.common.issues)},input:r.data})}}removeCatch(){return this._def.innerType}}return t.create=(n,e)=>new t({innerType:n,typeName:Jn.ZodCatch,catchValue:"function"==typeof e.catch?e.catch:()=>e.catch,...gi(e)}),t})(),pee=(()=>{class t extends wi{_parse(e){if(this._getType(e)!==yn.nan){const r=this._getOrReturnCtx(e);return bn(r,{code:sn.invalid_type,expected:yn.nan,received:r.parsedType}),hi}return{status:"valid",value:e.data}}}return t.create=n=>new t({typeName:Jn.ZodNaN,...gi(n)}),t})();const AKe=Symbol("zod_brand");class mee extends wi{_parse(n){const{ctx:e}=this._processInputParams(n);return this._def.type._parse({data:e.data,path:e.path,parent:e})}unwrap(){return this._def.type}}class Lh extends wi{_parse(n){var e=this;const{status:i,ctx:r}=this._processInputParams(n);if(r.common.async)return function(){var a=(0,Ge.Z)(function*(){const o=yield e._def.in._parseAsync({data:r.data,path:r.path,parent:r});return"aborted"===o.status?hi:"dirty"===o.status?(i.dirty(),aee(o.value)):e._def.out._parseAsync({data:o.value,path:r.path,parent:r})});return function(){return a.apply(this,arguments)}}()();{const s=this._def.in._parseSync({data:r.data,path:r.path,parent:r});return"aborted"===s.status?hi:"dirty"===s.status?(i.dirty(),{status:"dirty",value:s.value}):this._def.out._parseSync({data:s.value,path:r.path,parent:r})}}static create(n,e){return new Lh({in:n,out:e,typeName:Jn.ZodPipeline})}}let gee=(()=>{class t extends wi{_parse(e){const i=this._def.innerType._parse(e);return Ah(i)&&(i.value=Object.freeze(i.value)),i}}return t.create=(n,e)=>new t({innerType:n,typeName:Jn.ZodReadonly,...gi(e)}),t})();const vee=(t,n={},e)=>t?ty.create().superRefine((i,r)=>{var s,a;if(!t(i)){const o="function"==typeof n?n(i):"string"==typeof n?{message:n}:n,c=null===(a=null!==(s=o.fatal)&&void 0!==s?s:e)||void 0===a||a;r.addIssue({code:"custom",..."string"==typeof o?{message:o}:o,fatal:c})}}):ty.create(),IKe={object:Ed.lazycreate};var Jn=function(t){return t.ZodString="ZodString",t.ZodNumber="ZodNumber",t.ZodNaN="ZodNaN",t.ZodBigInt="ZodBigInt",t.ZodBoolean="ZodBoolean",t.ZodDate="ZodDate",t.ZodSymbol="ZodSymbol",t.ZodUndefined="ZodUndefined",t.ZodNull="ZodNull",t.ZodAny="ZodAny",t.ZodUnknown="ZodUnknown",t.ZodNever="ZodNever",t.ZodVoid="ZodVoid",t.ZodArray="ZodArray",t.ZodObject="ZodObject",t.ZodUnion="ZodUnion",t.ZodDiscriminatedUnion="ZodDiscriminatedUnion",t.ZodIntersection="ZodIntersection",t.ZodTuple="ZodTuple",t.ZodRecord="ZodRecord",t.ZodMap="ZodMap",t.ZodSet="ZodSet",t.ZodFunction="ZodFunction",t.ZodLazy="ZodLazy",t.ZodLiteral="ZodLiteral",t.ZodEnum="ZodEnum",t.ZodEffects="ZodEffects",t.ZodNativeEnum="ZodNativeEnum",t.ZodOptional="ZodOptional",t.ZodNullable="ZodNullable",t.ZodDefault="ZodDefault",t.ZodCatch="ZodCatch",t.ZodPromise="ZodPromise",t.ZodBranded="ZodBranded",t.ZodPipeline="ZodPipeline",t.ZodReadonly="ZodReadonly",t}(Jn||{});const yee=ey.create,_ee=xA.create,bee=MA.create,wee=G4.create;var it=Object.freeze({__proto__:null,defaultErrorMap:Eh,setErrorMap:function gKe(t){see=t},getErrorMap:Xv,makeIssue:Qv,EMPTY_PATH:[],addIssueToContext:bn,ParseStatus:Va,INVALID:hi,DIRTY:aee,OK:fo,isAborted:bA,isDirty:wA,isValid:Ah,isAsync:Jv,get util(){return Zi},get objectUtil(){return ree},ZodParsedType:yn,getParsedType:J3,ZodType:wi,ZodString:ey,ZodNumber:xA,ZodBigInt:TA,ZodBoolean:MA,ZodDate:kA,ZodSymbol:cee,ZodUndefined:SA,ZodNull:EA,ZodAny:ty,ZodUnknown:Ih,ZodNever:q4,ZodVoid:lee,ZodArray:Dh,ZodObject:Ed,ZodUnion:AA,ZodDiscriminatedUnion:iy,ZodIntersection:DA,ZodTuple:Ad,ZodRecord:Nh,ZodMap:uee,ZodSet:dee,ZodFunction:Id,ZodLazy:NA,ZodLiteral:RA,ZodEnum:ry,ZodNativeEnum:LA,ZodPromise:sy,ZodEffects:G4,ZodTransformer:G4,ZodOptional:Z4,ZodNullable:Rh,ZodDefault:PA,ZodCatch:hee,ZodNaN:pee,BRAND:AKe,ZodBranded:mee,ZodPipeline:Lh,ZodReadonly:gee,custom:vee,Schema:wi,ZodSchema:wi,late:IKe,get ZodFirstPartyTypeKind(){return Jn},coerce:{string:t=>ey.create({...t,coerce:!0}),number:t=>xA.create({...t,coerce:!0}),boolean:t=>MA.create({...t,coerce:!0}),bigint:t=>TA.create({...t,coerce:!0}),date:t=>kA.create({...t,coerce:!0})},any:ty.create,array:Dh.create,bigint:TA.create,boolean:bee,date:kA.create,discriminatedUnion:iy.create,effect:wee,enum:ry.create,function:Id.create,instanceof:(t,n={message:`Input not instance of ${t.name}`})=>vee(e=>e instanceof t,n),intersection:DA.create,lazy:NA.create,literal:RA.create,map:uee.create,nan:pee.create,nativeEnum:LA.create,never:q4.create,null:EA.create,nullable:Rh.create,number:_ee,object:Ed.create,oboolean:()=>bee().optional(),onumber:()=>_ee().optional(),optional:Z4.create,ostring:()=>yee().optional(),pipeline:Lh.create,preprocess:G4.createWithPreprocess,promise:sy.create,record:Nh.create,set:dee.create,strictObject:Ed.strictCreate,string:yee,symbol:cee.create,transformer:wee,tuple:Ad.create,undefined:SA.create,union:AA.create,unknown:Ih.create,void:lee.create,NEVER:hi,ZodIssueCode:sn,quotelessJson:t=>JSON.stringify(t,null,2).replace(/"([^"]+)":/g,"$1:"),ZodError:Nl});const Ca=it.object({message:it.string()});function Wn(t){return it.literal(cn[t])}it.object({accessList:it.array(it.string()),blockHash:it.string().nullable(),blockNumber:it.string().nullable(),chainId:it.string(),from:it.string(),gas:it.string(),hash:it.string(),input:it.string().nullable(),maxFeePerGas:it.string(),maxPriorityFeePerGas:it.string(),nonce:it.string(),r:it.string(),s:it.string(),to:it.string(),transactionIndex:it.string().nullable(),type:it.string(),v:it.string(),value:it.string()});const cXe=it.object({chainId:it.number()}),lXe=it.object({email:it.string().email()}),uXe=it.object({otp:it.string()}),dXe=it.object({chainId:it.optional(it.number()),preferredAccountType:it.optional(it.string())}),fXe=it.object({email:it.string().email()}),hXe=it.object({otp:it.string()}),pXe=it.object({otp:it.string()}),mXe=it.object({themeMode:it.optional(it.enum(["light","dark"])),themeVariables:it.optional(it.record(it.string(),it.string().or(it.number())))}),gXe=it.object({metadata:it.object({name:it.string(),description:it.string(),url:it.string(),icons:it.array(it.string())}).optional(),sdkVersion:it.string(),projectId:it.string()}),vXe=it.object({type:it.string()}),yXe=it.object({action:it.enum(["VERIFY_DEVICE","VERIFY_OTP"])}),_Xe=it.object({email:it.string().email(),address:it.string(),chainId:it.number(),smartAccountDeployed:it.optional(it.boolean()),preferredAccountType:it.optional(it.string())}),bXe=it.object({isConnected:it.boolean()}),wXe=it.object({chainId:it.number()}),CXe=it.object({chainId:it.number()}),xXe=it.object({newEmail:it.string().email()}),TXe=it.object({smartAccountEnabledNetworks:it.array(it.number())}),MXe=(it.object({address:it.string(),isDeployed:it.boolean()}),it.object({type:it.string(),address:it.string()})),kXe=it.any(),SXe=it.object({method:it.literal("eth_accounts")}),EXe=it.object({method:it.literal("eth_blockNumber")}),AXe=it.object({method:it.literal("eth_call"),params:it.array(it.any())}),IXe=it.object({method:it.literal("eth_chainId")}),DXe=it.object({method:it.literal("eth_estimateGas"),params:it.array(it.any())}),NXe=it.object({method:it.literal("eth_feeHistory"),params:it.array(it.any())}),RXe=it.object({method:it.literal("eth_gasPrice")}),LXe=it.object({method:it.literal("eth_getAccount"),params:it.array(it.any())}),PXe=it.object({method:it.literal("eth_getBalance"),params:it.array(it.any())}),zXe=it.object({method:it.literal("eth_getBlockByHash"),params:it.array(it.any())}),OXe=it.object({method:it.literal("eth_getBlockByNumber"),params:it.array(it.any())}),HXe=it.object({method:it.literal("eth_getBlockReceipts"),params:it.array(it.any())}),VXe=it.object({method:it.literal("eth_getBlockTransactionCountByHash"),params:it.array(it.any())}),FXe=it.object({method:it.literal("eth_getBlockTransactionCountByNumber"),params:it.array(it.any())}),BXe=it.object({method:it.literal("eth_getCode"),params:it.array(it.any())}),UXe=it.object({method:it.literal("eth_getFilterChanges"),params:it.array(it.any())}),$Xe=it.object({method:it.literal("eth_getFilterLogs"),params:it.array(it.any())}),jXe=it.object({method:it.literal("eth_getLogs"),params:it.array(it.any())}),WXe=it.object({method:it.literal("eth_getProof"),params:it.array(it.any())}),qXe=it.object({method:it.literal("eth_getStorageAt"),params:it.array(it.any())}),GXe=it.object({method:it.literal("eth_getTransactionByBlockHashAndIndex"),params:it.array(it.any())}),ZXe=it.object({method:it.literal("eth_getTransactionByBlockNumberAndIndex"),params:it.array(it.any())}),YXe=it.object({method:it.literal("eth_getTransactionByHash"),params:it.array(it.any())}),KXe=it.object({method:it.literal("eth_getTransactionCount"),params:it.array(it.any())}),XXe=it.object({method:it.literal("eth_getTransactionReceipt"),params:it.array(it.any())}),QXe=it.object({method:it.literal("eth_getUncleCountByBlockHash"),params:it.array(it.any())}),JXe=it.object({method:it.literal("eth_getUncleCountByBlockNumber"),params:it.array(it.any())}),eQe=it.object({method:it.literal("eth_maxPriorityFeePerGas")}),tQe=it.object({method:it.literal("eth_newBlockFilter")}),nQe=it.object({method:it.literal("eth_newFilter"),params:it.array(it.any())}),iQe=it.object({method:it.literal("eth_newPendingTransactionFilter")}),rQe=it.object({method:it.literal("eth_sendRawTransaction"),params:it.array(it.any())}),sQe=it.object({method:it.literal("eth_syncing"),params:it.array(it.any())}),aQe=it.object({method:it.literal("eth_uninstallFilter"),params:it.array(it.any())}),Cee=it.object({method:it.literal("personal_sign"),params:it.array(it.any())}),oQe=it.object({method:it.literal("eth_signTypedData_v4"),params:it.array(it.any())}),xee=it.object({method:it.literal("eth_sendTransaction"),params:it.array(it.any())}),Tee=it.object({token:it.string()}),ay={appEvent:it.object({type:Wn("APP_SWITCH_NETWORK"),payload:cXe}).or(it.object({type:Wn("APP_CONNECT_EMAIL"),payload:lXe})).or(it.object({type:Wn("APP_CONNECT_DEVICE")})).or(it.object({type:Wn("APP_CONNECT_OTP"),payload:uXe})).or(it.object({type:Wn("APP_GET_USER"),payload:it.optional(dXe)})).or(it.object({type:Wn("APP_SIGN_OUT")})).or(it.object({type:Wn("APP_IS_CONNECTED"),payload:it.optional(Tee)})).or(it.object({type:Wn("APP_GET_CHAIN_ID")})).or(it.object({type:Wn("APP_GET_SMART_ACCOUNT_ENABLED_NETWORKS")})).or(it.object({type:Wn("APP_INIT_SMART_ACCOUNT")})).or(it.object({type:Wn("APP_SET_PREFERRED_ACCOUNT"),payload:vXe})).or(it.object({type:Wn("APP_RPC_REQUEST"),payload:Cee.or(xee).or(SXe).or(EXe).or(AXe).or(IXe).or(DXe).or(NXe).or(RXe).or(LXe).or(PXe).or(zXe).or(OXe).or(HXe).or(VXe).or(FXe).or(BXe).or(UXe).or($Xe).or(jXe).or(WXe).or(qXe).or(GXe).or(ZXe).or(YXe).or(KXe).or(XXe).or(QXe).or(JXe).or(eQe).or(tQe).or(nQe).or(iQe).or(rQe).or(sQe).or(aQe).or(Cee).or(oQe).or(xee)})).or(it.object({type:Wn("APP_UPDATE_EMAIL"),payload:fXe})).or(it.object({type:Wn("APP_UPDATE_EMAIL_PRIMARY_OTP"),payload:hXe})).or(it.object({type:Wn("APP_UPDATE_EMAIL_SECONDARY_OTP"),payload:pXe})).or(it.object({type:Wn("APP_SYNC_THEME"),payload:mXe})).or(it.object({type:Wn("APP_SYNC_DAPP_DATA"),payload:gXe})),frameEvent:it.object({type:Wn("FRAME_SWITCH_NETWORK_ERROR"),payload:Ca}).or(it.object({type:Wn("FRAME_SWITCH_NETWORK_SUCCESS"),payload:CXe})).or(it.object({type:Wn("FRAME_CONNECT_EMAIL_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_CONNECT_EMAIL_SUCCESS"),payload:yXe})).or(it.object({type:Wn("FRAME_CONNECT_OTP_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_CONNECT_OTP_SUCCESS")})).or(it.object({type:Wn("FRAME_CONNECT_DEVICE_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_CONNECT_DEVICE_SUCCESS")})).or(it.object({type:Wn("FRAME_GET_USER_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_GET_USER_SUCCESS"),payload:_Xe})).or(it.object({type:Wn("FRAME_SIGN_OUT_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_SIGN_OUT_SUCCESS")})).or(it.object({type:Wn("FRAME_IS_CONNECTED_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_IS_CONNECTED_SUCCESS"),payload:bXe})).or(it.object({type:Wn("FRAME_GET_CHAIN_ID_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_GET_CHAIN_ID_SUCCESS"),payload:wXe})).or(it.object({type:Wn("FRAME_RPC_REQUEST_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_RPC_REQUEST_SUCCESS"),payload:kXe})).or(it.object({type:Wn("FRAME_SESSION_UPDATE"),payload:Tee})).or(it.object({type:Wn("FRAME_UPDATE_EMAIL_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_UPDATE_EMAIL_SUCCESS")})).or(it.object({type:Wn("FRAME_UPDATE_EMAIL_PRIMARY_OTP_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_UPDATE_EMAIL_PRIMARY_OTP_SUCCESS")})).or(it.object({type:Wn("FRAME_UPDATE_EMAIL_SECONDARY_OTP_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_UPDATE_EMAIL_SECONDARY_OTP_SUCCESS"),payload:xXe})).or(it.object({type:Wn("FRAME_SYNC_THEME_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_SYNC_THEME_SUCCESS")})).or(it.object({type:Wn("FRAME_SYNC_DAPP_DATA_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_SYNC_DAPP_DATA_SUCCESS")})).or(it.object({type:Wn("FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_SUCCESS"),payload:TXe})).or(it.object({type:Wn("FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_INIT_SMART_ACCOUNT_ERROR"),payload:Ca})).or(it.object({type:Wn("FRAME_SET_PREFERRED_ACCOUNT_SUCCESS"),payload:MXe})).or(it.object({type:Wn("FRAME_SET_PREFERRED_ACCOUNT_ERROR"),payload:Ca}))},Fa={set(t,n){es.isClient&&localStorage.setItem(`${cn.STORAGE_KEY}${t}`,n)},get:t=>es.isClient?localStorage.getItem(`${cn.STORAGE_KEY}${t}`):null,delete(t){es.isClient&&localStorage.removeItem(`${cn.STORAGE_KEY}${t}`)}},cQe=["ASIA/SHANGHAI","ASIA/URUMQI","ASIA/CHONGQING","ASIA/HARBIN","ASIA/KASHGAR","ASIA/MACAU","ASIA/HONG_KONG","ASIA/MACAO","ASIA/BEIJING","ASIA/HARBIN"],oy=3e4,es={getBlockchainApiUrl(){try{const{timeZone:t}=(new Intl.DateTimeFormat).resolvedOptions(),n=t.toUpperCase();return cQe.includes(n)?"https://rpc.walletconnect.org":"https://rpc.walletconnect.com"}catch{return!1}},checkIfAllowedToTriggerEmail(){const t=Fa.get(cn.LAST_EMAIL_LOGIN_TIME);if(t){const n=Date.now()-Number(t);if(n<oy){const e=Math.ceil((oy-n)/1e3);throw new Error(`Please try again after ${e} seconds`)}}},getTimeToNextEmailLogin(){const t=Fa.get(cn.LAST_EMAIL_LOGIN_TIME);if(t){const n=Date.now()-Number(t);if(n<oy)return Math.ceil((oy-n)/1e3)}return 0},checkIfRequestExists(t){const n=this.getRequestMethod(t);return wa.NOT_SAFE_RPC_METHODS.includes(n)||wa.SAFE_RPC_METHODS.includes(n)},getRequestMethod:t=>t?.payload?.method,checkIfRequestIsAllowed(t){const n=this.getRequestMethod(t);return wa.SAFE_RPC_METHODS.includes(n)},getPreferredAccountType:()=>Fa.get(cn.PREFERRED_ACCOUNT_TYPE)||wa.ACCOUNT_TYPES.EOA,isClient:typeof window<"u"};class lQe{constructor(n,e=!1){if(this.iframe=null,this.rpcUrl=es.getBlockchainApiUrl(),this.events={onFrameEvent:i=>{es.isClient&&window.addEventListener("message",({data:r})=>{if(!r.type?.includes(cn.FRAME_EVENT_KEY))return;const s=ay.frameEvent.parse(r);i(s)})},onAppEvent:i=>{es.isClient&&window.addEventListener("message",({data:r})=>{if(!r.type?.includes(cn.APP_EVENT_KEY))return;const s=ay.appEvent.parse(r);i(s)})},postAppEvent:i=>{if(es.isClient){if(!this.iframe?.contentWindow)throw new Error("W3mFrame: iframe is not set");ay.appEvent.parse(i),window.postMessage(i),this.iframe.contentWindow.postMessage(i,"*")}},postFrameEvent:i=>{if(es.isClient){if(!parent)throw new Error("W3mFrame: parent is not set");ay.frameEvent.parse(i),parent.postMessage(i,"*")}}},this.projectId=n,this.frameLoadPromise=new Promise((i,r)=>{this.frameLoadPromiseResolver={resolve:i,reject:r}}),e&&(this.frameLoadPromise=new Promise((i,r)=>{this.frameLoadPromiseResolver={resolve:i,reject:r}}),es.isClient)){const i=document.createElement("iframe");i.id="w3m-iframe",i.src=`${cn.SECURE_SITE_SDK}?projectId=${n}`,i.style.position="fixed",i.style.zIndex="999999",i.style.display="none",i.style.opacity="0",i.style.borderBottomLeftRadius="clamp(0px, var(--wui-border-radius-l), 44px)",i.style.borderBottomRightRadius="clamp(0px, var(--wui-border-radius-l), 44px)",document.body.appendChild(i),this.iframe=i,this.iframe.onload=()=>{this.frameLoadPromiseResolver?.resolve(void 0)},this.iframe.onerror=()=>{this.frameLoadPromiseResolver?.reject("Unable to load email login dependency")}}}get networks(){const n=[1,5,11155111,10,420,42161,421613,137,80001,42220,1313161554,1313161555,56,97,43114,43113,324,280,100,8453,84531,7777777,999].map(e=>({[e]:{rpcUrl:`${this.rpcUrl}/v1/?chainId=eip155:${e}&projectId=${this.projectId}`,chainId:e}}));return Object.assign({},...n)}}class uQe{constructor(n){this.connectEmailResolver=void 0,this.connectDeviceResolver=void 0,this.connectOtpResolver=void 0,this.connectResolver=void 0,this.disconnectResolver=void 0,this.isConnectedResolver=void 0,this.getChainIdResolver=void 0,this.switchChainResolver=void 0,this.rpcRequestResolver=void 0,this.updateEmailResolver=void 0,this.updateEmailPrimaryOtpResolver=void 0,this.updateEmailSecondaryOtpResolver=void 0,this.syncThemeResolver=void 0,this.syncDappDataResolver=void 0,this.smartAccountEnabledNetworksResolver=void 0,this.setPreferredAccountResolver=void 0,this.w3mFrame=new lQe(n,!0),this.w3mFrame.events.onFrameEvent(e=>{switch(console.log("\u{1f4bb} received",e),e.type){case cn.FRAME_CONNECT_EMAIL_SUCCESS:return this.onConnectEmailSuccess(e);case cn.FRAME_CONNECT_EMAIL_ERROR:return this.onConnectEmailError(e);case cn.FRAME_CONNECT_DEVICE_SUCCESS:return this.onConnectDeviceSuccess();case cn.FRAME_CONNECT_DEVICE_ERROR:return this.onConnectDeviceError(e);case cn.FRAME_CONNECT_OTP_SUCCESS:return this.onConnectOtpSuccess();case cn.FRAME_CONNECT_OTP_ERROR:return this.onConnectOtpError(e);case cn.FRAME_GET_USER_SUCCESS:return this.onConnectSuccess(e);case cn.FRAME_GET_USER_ERROR:return this.onConnectError(e);case cn.FRAME_IS_CONNECTED_SUCCESS:return this.onIsConnectedSuccess(e);case cn.FRAME_IS_CONNECTED_ERROR:return this.onIsConnectedError(e);case cn.FRAME_GET_CHAIN_ID_SUCCESS:return this.onGetChainIdSuccess(e);case cn.FRAME_GET_CHAIN_ID_ERROR:return this.onGetChainIdError(e);case cn.FRAME_SIGN_OUT_SUCCESS:return this.onSignOutSuccess();case cn.FRAME_SIGN_OUT_ERROR:return this.onSignOutError(e);case cn.FRAME_SWITCH_NETWORK_SUCCESS:return this.onSwitchChainSuccess(e);case cn.FRAME_SWITCH_NETWORK_ERROR:return this.onSwitchChainError(e);case cn.FRAME_RPC_REQUEST_SUCCESS:return this.onRpcRequestSuccess(e);case cn.FRAME_RPC_REQUEST_ERROR:return this.onRpcRequestError(e);case cn.FRAME_SESSION_UPDATE:return this.onSessionUpdate(e);case cn.FRAME_UPDATE_EMAIL_SUCCESS:return this.onUpdateEmailSuccess();case cn.FRAME_UPDATE_EMAIL_ERROR:return this.onUpdateEmailError(e);case cn.FRAME_UPDATE_EMAIL_PRIMARY_OTP_SUCCESS:return this.onUpdateEmailPrimaryOtpSuccess();case cn.FRAME_UPDATE_EMAIL_PRIMARY_OTP_ERROR:return this.onUpdateEmailPrimaryOtpError(e);case cn.FRAME_UPDATE_EMAIL_SECONDARY_OTP_SUCCESS:return this.onUpdateEmailSecondaryOtpSuccess(e);case cn.FRAME_UPDATE_EMAIL_SECONDARY_OTP_ERROR:return this.onUpdateEmailSecondaryOtpError(e);case cn.FRAME_SYNC_THEME_SUCCESS:return this.onSyncThemeSuccess();case cn.FRAME_SYNC_THEME_ERROR:return this.onSyncThemeError(e);case cn.FRAME_SYNC_DAPP_DATA_SUCCESS:return this.onSyncDappDataSuccess();case cn.FRAME_SYNC_DAPP_DATA_ERROR:return this.onSyncDappDataError(e);case cn.FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_SUCCESS:return this.onSmartAccountEnabledNetworksSuccess(e);case cn.FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_ERROR:return this.onSmartAccountEnabledNetworksError(e);case cn.FRAME_SET_PREFERRED_ACCOUNT_SUCCESS:return this.onPreferSmartAccountSuccess(e);case cn.FRAME_SET_PREFERRED_ACCOUNT_ERROR:return this.onPreferSmartAccountError();default:return null}})}getLoginEmailUsed(){return!!Fa.get(cn.EMAIL_LOGIN_USED_KEY)}getEmail(){return Fa.get(cn.EMAIL)}rejectRpcRequest(){this.rpcRequestResolver?.reject()}connectEmail(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,es.checkIfAllowedToTriggerEmail(),e.w3mFrame.events.postAppEvent({type:cn.APP_CONNECT_EMAIL,payload:n}),new Promise((i,r)=>{e.connectEmailResolver={resolve:i,reject:r}})})()}connectDevice(){var n=this;return(0,Ge.Z)(function*(){return yield n.w3mFrame.frameLoadPromise,n.w3mFrame.events.postAppEvent({type:cn.APP_CONNECT_DEVICE}),new Promise((e,i)=>{n.connectDeviceResolver={resolve:e,reject:i}})})()}connectOtp(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_CONNECT_OTP,payload:n}),new Promise((i,r)=>{e.connectOtpResolver={resolve:i,reject:r}})})()}isConnected(){var n=this;return(0,Ge.Z)(function*(){return yield n.w3mFrame.frameLoadPromise,n.w3mFrame.events.postAppEvent({type:cn.APP_IS_CONNECTED,payload:void 0}),new Promise((e,i)=>{n.isConnectedResolver={resolve:e,reject:i}})})()}getChainId(){var n=this;return(0,Ge.Z)(function*(){return yield n.w3mFrame.frameLoadPromise,n.w3mFrame.events.postAppEvent({type:cn.APP_GET_CHAIN_ID}),new Promise((e,i)=>{n.getChainIdResolver={resolve:e,reject:i}})})()}updateEmail(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,es.checkIfAllowedToTriggerEmail(),e.w3mFrame.events.postAppEvent({type:cn.APP_UPDATE_EMAIL,payload:n}),new Promise((i,r)=>{e.updateEmailResolver={resolve:i,reject:r}})})()}updateEmailPrimaryOtp(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_UPDATE_EMAIL_PRIMARY_OTP,payload:n}),new Promise((i,r)=>{e.updateEmailPrimaryOtpResolver={resolve:i,reject:r}})})()}updateEmailSecondaryOtp(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_UPDATE_EMAIL_SECONDARY_OTP,payload:n}),new Promise((i,r)=>{e.updateEmailSecondaryOtpResolver={resolve:i,reject:r}})})()}syncTheme(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_SYNC_THEME,payload:n}),new Promise((i,r)=>{e.syncThemeResolver={resolve:i,reject:r}})})()}syncDappData(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_SYNC_DAPP_DATA,payload:n}),new Promise((i,r)=>{e.syncDappDataResolver={resolve:i,reject:r}})})()}getSmartAccountEnabledNetworks(){var n=this;return(0,Ge.Z)(function*(){return yield n.w3mFrame.frameLoadPromise,n.w3mFrame.events.postAppEvent({type:cn.APP_GET_SMART_ACCOUNT_ENABLED_NETWORKS}),new Promise((e,i)=>{n.smartAccountEnabledNetworksResolver={resolve:e,reject:i}})})()}setPreferredAccount(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_SET_PREFERRED_ACCOUNT,payload:{type:n}}),new Promise((i,r)=>{e.setPreferredAccountResolver={resolve:i,reject:r}})})()}connect(n){var e=this;return(0,Ge.Z)(function*(){const i=n?.chainId??e.getLastUsedChainId()??1;return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_GET_USER,payload:{chainId:i,preferredAccountType:n?.preferredAccountType}}),new Promise((r,s)=>{e.connectResolver={resolve:r,reject:s}})})()}switchNetwork(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,e.w3mFrame.events.postAppEvent({type:cn.APP_SWITCH_NETWORK,payload:{chainId:n}}),new Promise((i,r)=>{e.switchChainResolver={resolve:i,reject:r}})})()}disconnect(){var n=this;return(0,Ge.Z)(function*(){return yield n.w3mFrame.frameLoadPromise,n.w3mFrame.events.postAppEvent({type:cn.APP_SIGN_OUT}),new Promise((e,i)=>{n.disconnectResolver={resolve:e,reject:i}})})()}request(n){var e=this;return(0,Ge.Z)(function*(){return yield e.w3mFrame.frameLoadPromise,wa.GET_CHAIN_ID===n.method?e.getLastUsedChainId():(e.w3mFrame.events.postAppEvent({type:cn.APP_RPC_REQUEST,payload:n}),new Promise((i,r)=>{e.rpcRequestResolver={resolve:i,reject:r}}))})()}onRpcRequest(n){this.w3mFrame.events.onAppEvent(e=>{e.type.includes(cn.RPC_METHOD_KEY)&&n(e)})}onRpcResponse(n){this.w3mFrame.events.onFrameEvent(e=>{e.type.includes(cn.RPC_METHOD_KEY)&&n(e)})}onIsConnected(n){this.w3mFrame.events.onFrameEvent(e=>{e.type===cn.FRAME_GET_USER_SUCCESS&&n(e.payload)})}onNotConnected(n){this.w3mFrame.events.onFrameEvent(e=>{e.type===cn.FRAME_IS_CONNECTED_ERROR&&n(),e.type===cn.FRAME_IS_CONNECTED_SUCCESS&&!e.payload.isConnected&&n()})}onSetPreferredAccount(n){this.w3mFrame.events.onFrameEvent(e=>{e.type===cn.FRAME_SET_PREFERRED_ACCOUNT_SUCCESS?n(e.payload):e.type===cn.FRAME_SET_PREFERRED_ACCOUNT_ERROR&&n({type:wa.ACCOUNT_TYPES.EOA})})}onGetSmartAccountEnabledNetworks(n){this.w3mFrame.events.onFrameEvent(e=>{e.type===cn.FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_SUCCESS?n(e.payload.smartAccountEnabledNetworks):e.type===cn.FRAME_GET_SMART_ACCOUNT_ENABLED_NETWORKS_ERROR&&n([])})}onConnectEmailSuccess(n){this.connectEmailResolver?.resolve(n.payload),this.setNewLastEmailLoginTime()}onConnectEmailError(n){this.connectEmailResolver?.reject(n.payload.message)}onConnectDeviceSuccess(){this.connectDeviceResolver?.resolve(void 0)}onConnectDeviceError(n){this.connectDeviceResolver?.reject(n.payload.message)}onConnectOtpSuccess(){this.connectOtpResolver?.resolve(void 0)}onConnectOtpError(n){this.connectOtpResolver?.reject(n.payload.message)}onConnectSuccess(n){this.setEmailLoginSuccess(n.payload.email),this.setLastUsedChainId(n.payload.chainId),this.connectResolver?.resolve(n.payload)}onConnectError(n){this.connectResolver?.reject(n.payload.message)}onIsConnectedSuccess(n){n.payload.isConnected||this.deleteEmailLoginCache(),this.isConnectedResolver?.resolve(n.payload)}onIsConnectedError(n){this.isConnectedResolver?.reject(n.payload.message)}onGetChainIdSuccess(n){this.setLastUsedChainId(n.payload.chainId),this.getChainIdResolver?.resolve(n.payload)}onGetChainIdError(n){this.getChainIdResolver?.reject(n.payload.message)}onSignOutSuccess(){this.disconnectResolver?.resolve(void 0),this.deleteEmailLoginCache()}onSignOutError(n){this.disconnectResolver?.reject(n.payload.message)}onSwitchChainSuccess(n){this.setLastUsedChainId(n.payload.chainId),this.switchChainResolver?.resolve(n.payload)}onSwitchChainError(n){this.switchChainResolver?.reject(n.payload.message)}onRpcRequestSuccess(n){this.rpcRequestResolver?.resolve(n.payload)}onRpcRequestError(n){this.rpcRequestResolver?.reject(n.payload.message)}onSessionUpdate(n){}onUpdateEmailSuccess(){this.updateEmailResolver?.resolve(void 0),this.setNewLastEmailLoginTime()}onUpdateEmailError(n){this.updateEmailResolver?.reject(n.payload.message)}onUpdateEmailPrimaryOtpSuccess(){this.updateEmailPrimaryOtpResolver?.resolve(void 0)}onUpdateEmailPrimaryOtpError(n){this.updateEmailPrimaryOtpResolver?.reject(n.payload.message)}onUpdateEmailSecondaryOtpSuccess(n){const{newEmail:e}=n.payload;this.setEmailLoginSuccess(e),this.updateEmailSecondaryOtpResolver?.resolve({newEmail:e})}onUpdateEmailSecondaryOtpError(n){this.updateEmailSecondaryOtpResolver?.reject(n.payload.message)}onSyncThemeSuccess(){this.syncThemeResolver?.resolve(void 0)}onSyncThemeError(n){this.syncThemeResolver?.reject(n.payload.message)}onSyncDappDataSuccess(){this.syncDappDataResolver?.resolve(void 0)}onSyncDappDataError(n){this.syncDappDataResolver?.reject(n.payload.message)}onSmartAccountEnabledNetworksSuccess(n){this.persistSmartAccountEnabledNetworks(n.payload.smartAccountEnabledNetworks),this.smartAccountEnabledNetworksResolver?.resolve(n.payload)}onSmartAccountEnabledNetworksError(n){this.persistSmartAccountEnabledNetworks([]),this.smartAccountEnabledNetworksResolver?.reject(n.payload.message)}onPreferSmartAccountSuccess(n){this.persistPreferredAccount(n.payload.type),this.setPreferredAccountResolver?.resolve(void 0)}onPreferSmartAccountError(){this.setPreferredAccountResolver?.reject()}setNewLastEmailLoginTime(){Fa.set(cn.LAST_EMAIL_LOGIN_TIME,Date.now().toString())}setEmailLoginSuccess(n){Fa.set(cn.EMAIL,n),Fa.set(cn.EMAIL_LOGIN_USED_KEY,"true"),Fa.delete(cn.LAST_EMAIL_LOGIN_TIME)}deleteEmailLoginCache(){Fa.delete(cn.EMAIL_LOGIN_USED_KEY),Fa.delete(cn.EMAIL),Fa.delete(cn.LAST_USED_CHAIN_KEY)}setLastUsedChainId(n){Fa.set(cn.LAST_USED_CHAIN_KEY,String(n))}getLastUsedChainId(){return Number(Fa.get(cn.LAST_USED_CHAIN_KEY))}persistPreferredAccount(n){Fa.set(cn.PREFERRED_ACCOUNT_TYPE,n)}persistSmartAccountEnabledNetworks(n){Fa.set(cn.SMART_ACCOUNT_ENABLED_NETWORKS,n.join(","))}}var Y4=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Rl=class extends Ke.oi{constructor(){super(),this.usubscribe=[],this.networkImages=ue.WM.state.networkImages,this.address=ue.AccountController.state.address,this.profileImage=ue.AccountController.state.profileImage,this.profileName=ue.AccountController.state.profileName,this.network=ue.NetworkController.state.caipNetwork,this.disconnecting=!1,this.loading=!1,this.usubscribe.push(ue.AccountController.subscribe(n=>{n.address?(this.address=n.address,this.profileImage=n.profileImage,this.profileName=n.profileName):ue.IN.close()}),ue.NetworkController.subscribeKey("caipNetwork",n=>{n?.id&&(this.network=n)}))}disconnectedCallback(){this.usubscribe.forEach(n=>n())}render(){if(!this.address)throw new Error("w3m-account-settings-view: No account provided");const n=this.networkImages[this.network?.imageId??""];return Ke.dy`
      <wui-flex
        flexDirection="column"
        .padding=${["0","xl","m","xl"]}
        alignItems="center"
        gap="l"
      >
        <wui-avatar
          alt=${this.address}
          address=${this.address}
          imageSrc=${jn(this.profileImage)}
        ></wui-avatar>
        <wui-flex flexDirection="column" alignItems="center">
          <wui-flex gap="3xs" alignItems="center" justifyContent="center">
            <wui-text variant="large-600" color="fg-100" data-testid="account-settings-address">
              ${Xt.UiHelperUtil.getTruncateString(this.profileName?{string:this.profileName,charsStart:20,charsEnd:0,truncate:"end"}:{string:this.address,charsStart:4,charsEnd:6,truncate:"middle"})}
            </wui-text>
            <wui-icon-link
              size="md"
              icon="copy"
              iconColor="fg-200"
              @click=${this.onCopyAddress}
            ></wui-icon-link>
          </wui-flex>
        </wui-flex>
      </wui-flex>

      <wui-flex flexDirection="column" gap="m">
        <wui-flex flexDirection="column" gap="xs" .padding=${["0","xl","m","xl"]}>
          ${this.emailBtnTemplate()}
          <wui-list-item
            .variant=${n?"image":"icon"}
            iconVariant="overlay"
            icon="networkPlaceholder"
            imageSrc=${jn(n)}
            ?chevron=${this.isAllowedNetworkSwitch()}
            @click=${this.onNetworks.bind(this)}
            data-testid="account-switch-network-button"
          >
            <wui-text variant="paragraph-500" color="fg-100">
              ${this.network?.name??"Unknown"}
            </wui-text>
          </wui-list-item>
          ${this.togglePreferredAccountBtnTemplate()}
          <wui-list-item
            variant="icon"
            iconVariant="overlay"
            icon="disconnect"
            ?chevron=${!1}
            .loading=${this.disconnecting}
            @click=${this.onDisconnect.bind(this)}
            data-testid="disconnect-button"
          >
            <wui-text variant="paragraph-500" color="fg-200">Disconnect</wui-text>
          </wui-list-item>
        </wui-flex>
      </wui-flex>
    `}isAllowedNetworkSwitch(){const{requestedCaipNetworks:n}=ue.NetworkController.state,e=!!n&&n.length>1,i=n?.find(({id:r})=>r===this.network?.id);return e||!i}onCopyAddress(){try{this.address&&(ue.j1.copyToClopboard(this.address),ue.SnackController.showSuccess("Address copied"))}catch{ue.SnackController.showError("Failed to copy")}}emailBtnTemplate(){const n=ue.MO.getConnectedConnector(),e=ue.ConnectorController.getEmailConnector();if(!e||"EMAIL"!==n)return null;const i=e.provider.getEmail()??"";return Ke.dy`
      <wui-list-item
        variant="icon"
        iconVariant="overlay"
        icon="mail"
        iconSize="sm"
        ?chevron=${!0}
        @click=${()=>this.onGoToUpdateEmail(i)}
      >
        <wui-text variant="paragraph-500" color="fg-100">${i}</wui-text>
      </wui-list-item>
    `}togglePreferredAccountBtnTemplate(){const n=ue.NetworkController.checkIfSmartAccountEnabled(),e=ue.MO.getConnectedConnector();if(!ue.ConnectorController.getEmailConnector()||"EMAIL"!==e||!n)return null;const s=es.getPreferredAccountType()===wa.ACCOUNT_TYPES.SMART_ACCOUNT?"Switch to your EOA":"Switch to your smart account";return Ke.dy`
      <wui-list-item
        variant="icon"
        iconVariant="overlay"
        icon="swapHorizontalBold"
        iconSize="sm"
        ?chevron=${!0}
        ?loading=${this.loading}
        @click=${this.changePreferredAccountType.bind(this)}
        data-testid="account-toggle-preferred-account-type"
      >
        <wui-text variant="paragraph-500" color="fg-100">${s}</wui-text>
      </wui-list-item>
    `}changePreferredAccountType(){var n=this;return(0,Ge.Z)(function*(){const e=ue.NetworkController.checkIfSmartAccountEnabled(),r=es.getPreferredAccountType()!==wa.ACCOUNT_TYPES.SMART_ACCOUNT&&e?wa.ACCOUNT_TYPES.SMART_ACCOUNT:wa.ACCOUNT_TYPES.EOA,s=ue.ConnectorController.getEmailConnector();s&&(n.loading=!0,yield s?.provider.setPreferredAccount(r),n.loading=!1,n.requestUpdate())})()}onGoToUpdateEmail(n){ue.RouterController.push("UpdateEmailWallet",{email:n})}onNetworks(){this.isAllowedNetworkSwitch()&&ue.RouterController.push("Networks")}onDisconnect(){var n=this;return(0,Ge.Z)(function*(){try{n.disconnecting=!0,yield ue.ConnectionController.disconnect(),ue.Xs.sendEvent({type:"track",event:"DISCONNECT_SUCCESS"}),ue.IN.close()}catch{ue.Xs.sendEvent({type:"track",event:"DISCONNECT_ERROR"}),ue.SnackController.showError("Failed to disconnect")}finally{n.disconnecting=!1}})()}};Rl.styles=hKe,Y4([(0,bt.SB)()],Rl.prototype,"address",void 0),Y4([(0,bt.SB)()],Rl.prototype,"profileImage",void 0),Y4([(0,bt.SB)()],Rl.prototype,"profileName",void 0),Y4([(0,bt.SB)()],Rl.prototype,"network",void 0),Y4([(0,bt.SB)()],Rl.prototype,"disconnecting",void 0),Y4([(0,bt.SB)()],Rl.prototype,"loading",void 0),Rl=Y4([(0,Xt.customElement)("w3m-account-settings-view")],Rl);let Mee=class extends Ke.oi{render(){const n=ue.MO.getConnectedConnector();return Ke.dy`
      ${ue.OptionsController.state.enableWalletFeatures&&"EMAIL"===n?this.walletFeaturesTemplate():this.defaultTemplate()}
    `}walletFeaturesTemplate(){return Ke.dy`<w3m-account-wallet-features-widget></w3m-account-wallet-features-widget>`}defaultTemplate(){return Ke.dy`<w3m-account-default-widget></w3m-account-default-widget>`}};Mee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-account-view")],Mee);var kee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let zA=class extends Ke.oi{constructor(){super(...arguments),this.search="",this.onDebouncedSearch=ue.j1.debounce(n=>{this.search=n})}render(){const n=this.search.length>=2;return Ke.dy`
      <wui-flex padding="s" gap="s">
        <wui-search-bar @inputChange=${this.onInputChange.bind(this)}></wui-search-bar>
        ${this.qrButtonTemplate()}
      </wui-flex>
      ${n?Ke.dy`<w3m-all-wallets-search query=${this.search}></w3m-all-wallets-search>`:Ke.dy`<w3m-all-wallets-list></w3m-all-wallets-list>`}
    `}onInputChange(n){this.onDebouncedSearch(n.detail)}qrButtonTemplate(){return ue.j1.isMobile()?Ke.dy`
        <wui-icon-box
          size="lg"
          iconSize="xl"
          iconColor="accent-100"
          backgroundColor="accent-100"
          icon="qrCode"
          background="transparent"
          border
          borderColor="wui-accent-glass-010"
          @click=${this.onWalletConnectQr.bind(this)}
        ></wui-icon-box>
      `:null}onWalletConnectQr(){ue.RouterController.push("ConnectingWalletConnect")}};kee([(0,bt.SB)()],zA.prototype,"search",void 0),zA=kee([(0,Xt.customElement)("w3m-all-wallets-view")],zA);const fQe=Ke.iv`
  @keyframes shake {
    0% {
      transform: translateX(0);
    }
    25% {
      transform: translateX(3px);
    }
    50% {
      transform: translateX(-3px);
    }
    75% {
      transform: translateX(3px);
    }
    100% {
      transform: translateX(0);
    }
  }

  wui-flex:first-child:not(:only-child) {
    position: relative;
  }

  wui-loading-thumbnail {
    position: absolute;
  }

  wui-visual {
    width: var(--wui-wallet-image-size-lg);
    height: var(--wui-wallet-image-size-lg);
    border-radius: calc(var(--wui-border-radius-5xs) * 9 - var(--wui-border-radius-xxs));
    position: relative;
    overflow: hidden;
  }

  wui-visual::after {
    content: '';
    display: block;
    width: 100%;
    height: 100%;
    position: absolute;
    inset: 0;
    border-radius: calc(var(--wui-border-radius-5xs) * 9 - var(--wui-border-radius-xxs));
    box-shadow: inset 0 0 0 1px var(--wui-gray-glass-005);
  }

  wui-icon-box {
    position: absolute;
    right: calc(var(--wui-spacing-3xs) * -1);
    bottom: calc(var(--wui-spacing-3xs) * -1);
    opacity: 0;
    transform: scale(0.5);
    transition:
      opacity var(--wui-ease-out-power-2) var(--wui-duration-lg),
      transform var(--wui-ease-out-power-2) var(--wui-duration-lg);
    will-change: opacity, transform;
  }

  wui-text[align='center'] {
    width: 100%;
    padding: 0px var(--wui-spacing-l);
  }

  [data-error='true'] wui-icon-box {
    opacity: 1;
    transform: scale(1);
  }

  [data-error='true'] > wui-flex:first-child {
    animation: shake 250ms cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
  }

  [data-retry='false'] wui-link {
    display: none;
  }

  [data-retry='true'] wui-link {
    display: block;
    opacity: 1;
  }

  wui-link {
    padding: var(--wui-spacing-4xs) var(--wui-spacing-xxs);
  }
`;var W2=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let A1=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.selectedOnRampProvider=ue.ph.state.selectedProvider,this.uri=ue.ConnectionController.state.wcUri,this.ready=!1,this.showRetry=!1,this.buffering=!1,this.error=!1,this.startTime=null,this.isMobile=!1,this.onRetry=void 0,this.unsubscribe.push(ue.ph.subscribeKey("selectedProvider",n=>{this.selectedOnRampProvider=n})),this.watchTransactions()}disconnectedCallback(){this.intervalId&&clearInterval(this.intervalId)}render(){let n="Continue in external window";this.error?n="Buy failed":this.selectedOnRampProvider&&(n=`Buy in ${this.selectedOnRampProvider?.label}`);const e=this.error?"Buy can be declined from your side or due to and error on the provider app":"We\u2019ll notify you once your Buy is processed";return Ke.dy`
      <wui-flex
        data-error=${jn(this.error)}
        data-retry=${this.showRetry}
        flexDirection="column"
        alignItems="center"
        .padding=${["3xl","xl","xl","xl"]}
        gap="xl"
      >
        <wui-flex justifyContent="center" alignItems="center">
          <wui-visual
            name=${jn(this.selectedOnRampProvider?.name)}
            size="lg"
            class="provider-image"
          >
          </wui-visual>

          ${this.error?null:this.loaderTemplate()}

          <wui-icon-box
            backgroundColor="error-100"
            background="opaque"
            iconColor="error-100"
            icon="close"
            size="sm"
            border
            borderColor="wui-color-bg-125"
          ></wui-icon-box>
        </wui-flex>

        <wui-flex flexDirection="column" alignItems="center" gap="xs">
          <wui-text variant="paragraph-500" color=${this.error?"error-100":"fg-100"}>
            ${n}
          </wui-text>
          <wui-text align="center" variant="small-500" color="fg-200">${e}</wui-text>
        </wui-flex>

        ${this.error?this.tryAgainTemplate():null}
      </wui-flex>

      <wui-flex .padding=${["0","xl","xl","xl"]} justifyContent="center">
        <wui-link @click=${this.onCopyUri} color="fg-200">
          <wui-icon size="xs" color="fg-200" slot="iconLeft" name="copy"></wui-icon>
          Copy link
        </wui-link>
      </wui-flex>
    `}watchTransactions(){this.selectedOnRampProvider&&"coinbase"===this.selectedOnRampProvider.name&&(this.startTime=Date.now(),this.initializeCoinbaseTransactions())}initializeCoinbaseTransactions(){var n=this;return(0,Ge.Z)(function*(){yield n.watchCoinbaseTransactions(),n.intervalId=setInterval(()=>n.watchCoinbaseTransactions(),4e3)})()}watchCoinbaseTransactions(){var n=this;return(0,Ge.Z)(function*(){try{const e=ue.AccountController.state.address,i=ue.OptionsController.state.projectId;if(!e)throw new Error("No address found");(yield ue.Lr.fetchTransactions({account:e,onramp:"coinbase",projectId:i})).data.filter(a=>new Date(a.metadata.minedAt)>new Date(n.startTime)||"ONRAMP_TRANSACTION_STATUS_IN_PROGRESS"===a.metadata.status).length?(clearInterval(n.intervalId),ue.RouterController.replace("OnRampActivity")):n.startTime&&Date.now()-n.startTime>=18e4&&(clearInterval(n.intervalId),n.error=!0)}catch(e){ue.SnackController.showError(e)}})()}onTryAgain(){this.selectedOnRampProvider&&(this.error=!1,ue.j1.openHref(this.selectedOnRampProvider.url,"popupWindow","width=600,height=800,scrollbars=yes"))}tryAgainTemplate(){return this.selectedOnRampProvider?.url?Ke.dy`<wui-button variant="accent" @click=${this.onTryAgain.bind(this)}>
      <wui-icon color="inherit" slot="iconLeft" name="refresh"></wui-icon>
      Try again
    </wui-button>`:null}loaderTemplate(){const n=ue.ThemeController.state.themeVariables["--w3m-border-radius-master"],e=n?parseInt(n.replace("px",""),10):4;return Ke.dy`<wui-loading-thumbnail radius=${9*e}></wui-loading-thumbnail>`}onCopyUri(){if(!this.selectedOnRampProvider?.url)return ue.SnackController.showError("No link found"),void ue.RouterController.goBack();try{ue.j1.copyToClopboard(this.selectedOnRampProvider.url),ue.SnackController.showSuccess("Link copied")}catch{ue.SnackController.showError("Failed to copy")}}};A1.styles=fQe,W2([(0,bt.SB)()],A1.prototype,"selectedOnRampProvider",void 0),W2([(0,bt.SB)()],A1.prototype,"uri",void 0),W2([(0,bt.SB)()],A1.prototype,"ready",void 0),W2([(0,bt.SB)()],A1.prototype,"showRetry",void 0),W2([(0,bt.SB)()],A1.prototype,"buffering",void 0),W2([(0,bt.SB)()],A1.prototype,"error",void 0),W2([(0,bt.SB)()],A1.prototype,"intervalId",void 0),W2([(0,bt.SB)()],A1.prototype,"startTime",void 0),W2([(0,bt.Cb)({type:Boolean})],A1.prototype,"isMobile",void 0),W2([(0,bt.Cb)()],A1.prototype,"onRetry",void 0),A1=W2([(0,Xt.customElement)("w3m-buy-in-progress-view")],A1);const hQe=Ke.iv`
  wui-flex {
    max-height: clamp(360px, 540px, 80vh);
    overflow: scroll;
    scrollbar-width: none;
  }

  wui-flex::-webkit-scrollbar {
    display: none;
  }
`,si={WALLET_CONNECT_CONNECTOR_ID:"walletConnect",INJECTED_CONNECTOR_ID:"injected",COINBASE_CONNECTOR_ID:"coinbaseWallet",COINBASE_SDK_CONNECTOR_ID:"coinbaseWalletSDK",SAFE_CONNECTOR_ID:"safe",LEDGER_CONNECTOR_ID:"ledger",EIP6963_CONNECTOR_ID:"eip6963",EMAIL_CONNECTOR_ID:"w3mEmail",EIP155:"eip155",ADD_CHAIN_METHOD:"wallet_addEthereumChain",EIP6963_ANNOUNCE_EVENT:"eip6963:announceProvider",EIP6963_REQUEST_EVENT:"eip6963:requestProvider",CONNECTOR_RDNS_MAP:{coinbaseWallet:"com.coinbase.wallet"},VERSION:"4.1.9"},Ll={ConnectorExplorerIds:{[si.COINBASE_CONNECTOR_ID]:"fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa",[si.SAFE_CONNECTOR_ID]:"225affb176778569276e484e1b92637ad061b01e13a048b35a9d280c3b58970f",[si.LEDGER_CONNECTOR_ID]:"19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927"},EIP155NetworkImageIds:{1:"692ed6ba-e569-459a-556a-776476829e00",42161:"3bff954d-5cb0-47a0-9a23-d20192e74600",43114:"30c46e53-e989-45fb-4549-be3bd4eb3b00",56:"93564157-2e8e-4ce7-81df-b264dbee9b00",250:"06b26297-fe0c-4733-5d6b-ffa5498aac00",10:"ab9c186a-c52f-464b-2906-ca59d760a400",137:"41d04d42-da3b-4453-8506-668cc0727900",100:"02b53f6a-e3d4-479e-1cb4-21178987d100",9001:"f926ff41-260d-4028-635e-91913fc28e00",324:"b310f07f-4ef7-49f3-7073-2a0a39685800",314:"5a73b3dd-af74-424e-cae0-0de859ee9400",4689:"34e68754-e536-40da-c153-6ef2e7188a00",1088:"3897a66d-40b9-4833-162f-a2c90531c900",1284:"161038da-44ae-4ec7-1208-0ea569454b00",1285:"f1d73bb6-5450-4e18-38f7-fb6484264a00",7777777:"845c60df-d429-4991-e687-91ae45791600",42220:"ab781bbc-ccc6-418d-d32d-789b15da1f00",8453:"7289c336-3981-4081-c5f4-efc26ac64a00",1313161554:"3ff73439-a619-4894-9262-4470c773a100",2020:"b8101fc0-9c19-4b6f-ec65-f6dfff106e00",2021:"b8101fc0-9c19-4b6f-ec65-f6dfff106e00","5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp":"a1b58899-f671-4276-6a5e-56ca5bd59700","4uhcVJyU9pJkvQyS88uRDiswHXSCkY3z":"a1b58899-f671-4276-6a5e-56ca5bd59700",EtWTRABZaYq6iMfeYKouRu166VU2xqa1:"a1b58899-f671-4276-6a5e-56ca5bd59700"},ConnectorImageIds:{[si.COINBASE_CONNECTOR_ID]:"0c2840c3-5b04-4c44-9661-fbd4b49e1800",[si.COINBASE_SDK_CONNECTOR_ID]:"0c2840c3-5b04-4c44-9661-fbd4b49e1800",[si.SAFE_CONNECTOR_ID]:"461db637-8616-43ce-035a-d89b8a1d5800",[si.LEDGER_CONNECTOR_ID]:"54a1aa77-d202-4f8d-0fb2-5d2bb6db0300",[si.WALLET_CONNECT_CONNECTOR_ID]:"ef1a1fcf-7fe8-4d69-bd6d-fda1345b4400",[si.INJECTED_CONNECTOR_ID]:"07ba87ed-43aa-4adf-4540-9e6a2b9cae00"},ConnectorNamesMap:{[si.INJECTED_CONNECTOR_ID]:"Browser Wallet",[si.WALLET_CONNECT_CONNECTOR_ID]:"WalletConnect",[si.COINBASE_CONNECTOR_ID]:"Coinbase",[si.COINBASE_SDK_CONNECTOR_ID]:"Coinbase",[si.LEDGER_CONNECTOR_ID]:"Ledger",[si.SAFE_CONNECTOR_ID]:"Safe"},ConnectorTypesMap:{[si.INJECTED_CONNECTOR_ID]:"INJECTED",[si.WALLET_CONNECT_CONNECTOR_ID]:"WALLET_CONNECT",[si.EIP6963_CONNECTOR_ID]:"ANNOUNCED",[si.EMAIL_CONNECTOR_ID]:"EMAIL"},WalletConnectRpcChainIds:[1,5,11155111,10,420,42161,421613,137,80001,42220,1313161554,1313161555,56,97,43114,43113,100,8453,84531,7777777,999,324,280]},pQe={getCaipTokens(t){if(!t)return;const n={};return Object.entries(t).forEach(([e,i])=>{n[`${si.EIP155}:${e}`]=i}),n}};var OA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Ph=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.connectors=ue.ConnectorController.state.connectors,this.count=ue.ApiController.state.count,this.unsubscribe.push(ue.ConnectorController.subscribeKey("connectors",n=>this.connectors=n),ue.ApiController.subscribeKey("count",n=>this.count=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-flex flexDirection="column" padding="s" gap="xs">
        <w3m-email-login-widget></w3m-email-login-widget>

        ${this.walletConnectConnectorTemplate()} ${this.recentTemplate()}
        ${this.announcedTemplate()} ${this.injectedTemplate()} ${this.featuredTemplate()}
        ${this.customTemplate()} ${this.recommendedTemplate()} ${this.externalTemplate()}
        ${this.allWalletsTemplate()}
      </wui-flex>
      <w3m-legal-footer></w3m-legal-footer>
    `}walletConnectConnectorTemplate(){if(ue.j1.isMobile())return null;const n=this.connectors.find(e=>"WALLET_CONNECT"===e.type);return n?Ke.dy`
      <wui-list-wallet
        imageSrc=${jn(ue.fz.getConnectorImage(n))}
        name=${n.name??"Unknown"}
        @click=${()=>this.onConnector(n)}
        tagLabel="qr code"
        tagVariant="main"
        data-testid="wallet-selector-walletconnect"
      >
      </wui-list-wallet>
    `:null}customTemplate(){const{customWallets:n}=ue.OptionsController.state;return n?.length?this.filterOutDuplicateWallets(n).map(i=>Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getWalletImage(i))}
          name=${i.name??"Unknown"}
          @click=${()=>this.onConnectWallet(i)}
          data-testid=${`wallet-selector-${i.id}`}
        >
        </wui-list-wallet>
      `):null}featuredTemplate(){if(!this.connectors.find(r=>"WALLET_CONNECT"===r.type))return null;const{featured:e}=ue.ApiController.state;return e.length?this.filterOutDuplicateWallets(e).map(r=>Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getWalletImage(r))}
          name=${r.name??"Unknown"}
          @click=${()=>this.onConnectWallet(r)}
        >
        </wui-list-wallet>
      `):null}recentTemplate(){return ue.MO.getRecentWallets().map(e=>Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getWalletImage(e))}
          name=${e.name??"Unknown"}
          @click=${()=>this.onConnectWallet(e)}
          tagLabel="recent"
          tagVariant="shade"
        >
        </wui-list-wallet>
      `)}announcedTemplate(){return this.connectors.map(n=>"ANNOUNCED"!==n.type?null:Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getConnectorImage(n))}
          name=${n.name??"Unknown"}
          @click=${()=>this.onConnector(n)}
          tagVariant="success"
          .installed=${!0}
        >
        </wui-list-wallet>
      `)}injectedTemplate(){return this.connectors.map(n=>"INJECTED"===n.type&&ue.ConnectionController.checkInstalled()?Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getConnectorImage(n))}
          .installed=${!0}
          name=${n.name??"Unknown"}
          @click=${()=>this.onConnector(n)}
        >
        </wui-list-wallet>
      `:null)}externalTemplate(){const n=ue.ConnectorController.getAnnouncedConnectorRdns();return this.connectors.map(e=>["WALLET_CONNECT","INJECTED","ANNOUNCED","EMAIL"].includes(e.type)||n.includes(si.CONNECTOR_RDNS_MAP[e.id])?null:Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getConnectorImage(e))}
          name=${e.name??"Unknown"}
          @click=${()=>this.onConnector(e)}
        >
        </wui-list-wallet>
      `)}allWalletsTemplate(){const n=this.connectors.find(o=>"WALLET_CONNECT"===o.type),{allWallets:e}=ue.OptionsController.state;if(!n||"HIDE"===e||"ONLY_MOBILE"===e&&!ue.j1.isMobile())return null;const r=this.count+ue.ApiController.state.featured.length,s=r<10?r:10*Math.floor(r/10),a=s<r?`${s}+`:`${s}`;return Ke.dy`
      <wui-list-wallet
        name="All Wallets"
        walletIcon="allWallets"
        showAllWallets
        @click=${this.onAllWallets.bind(this)}
        tagLabel=${a}
        tagVariant="shade"
        data-testid="all-wallets"
      ></wui-list-wallet>
    `}recommendedTemplate(){if(!this.connectors.find(h=>"WALLET_CONNECT"===h.type))return null;const{recommended:e}=ue.ApiController.state,{customWallets:i,featuredWalletIds:r}=ue.OptionsController.state,{connectors:s}=ue.ConnectorController.state,a=ue.MO.getRecentWallets(),c=s.filter(h=>"INJECTED"===h.type).filter(h=>"Browser Wallet"!==h.name);if(r||i||!e.length)return null;const u=Math.max(0,2-(c.length+a.length));return this.filterOutDuplicateWallets(e).slice(0,u).map(h=>Ke.dy`
        <wui-list-wallet
          imageSrc=${jn(ue.fz.getWalletImage(h))}
          name=${h?.name??"Unknown"}
          @click=${()=>this.onConnectWallet(h)}
        >
        </wui-list-wallet>
      `)}onConnector(n){"WALLET_CONNECT"===n.type?ue.j1.isMobile()?ue.RouterController.push("AllWallets"):ue.RouterController.push("ConnectingWalletConnect"):ue.RouterController.push("ConnectingExternal",{connector:n})}filterOutDuplicateWallets(n){const e=ue.MO.getRecentWallets(),i=this.connectors.map(o=>o.info?.rdns).filter(Boolean),r=e.map(o=>o.rdns).filter(Boolean),s=i.concat(r);return n.filter(o=>!s.includes(String(o?.rdns)))}onAllWallets(){ue.Xs.sendEvent({type:"track",event:"CLICK_ALL_WALLETS"}),ue.RouterController.push("AllWallets")}onConnectWallet(n){ue.RouterController.push("ConnectingWalletConnect",{wallet:n})}};Ph.styles=hQe,OA([(0,bt.SB)()],Ph.prototype,"connectors",void 0),OA([(0,bt.SB)()],Ph.prototype,"count",void 0),Ph=OA([(0,Xt.customElement)("w3m-connect-view")],Ph);const mQe=Ke.iv`
  @keyframes shake {
    0% {
      transform: translateX(0);
    }
    25% {
      transform: translateX(3px);
    }
    50% {
      transform: translateX(-3px);
    }
    75% {
      transform: translateX(3px);
    }
    100% {
      transform: translateX(0);
    }
  }

  wui-flex:first-child:not(:only-child) {
    position: relative;
  }

  wui-loading-thumbnail {
    position: absolute;
  }

  wui-icon-box {
    position: absolute;
    right: calc(var(--wui-spacing-3xs) * -1);
    bottom: calc(var(--wui-spacing-3xs) * -1);
    opacity: 0;
    transform: scale(0.5);
    transition-property: opacity, transform;
    transition-duration: var(--wui-duration-lg);
    transition-timing-function: var(--wui-ease-out-power-2);
    will-change: opacity, transform;
  }

  wui-text[align='center'] {
    width: 100%;
    padding: 0px var(--wui-spacing-l);
  }

  [data-error='true'] wui-icon-box {
    opacity: 1;
    transform: scale(1);
  }

  [data-error='true'] > wui-flex:first-child {
    animation: shake 250ms cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
  }

  [data-retry='false'] wui-link {
    display: none;
  }

  [data-retry='true'] wui-link {
    display: block;
    opacity: 1;
  }
`;var K4=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};class Uo extends Ke.oi{constructor(){super(),this.wallet=ue.RouterController.state.data?.wallet,this.connector=ue.RouterController.state.data?.connector,this.timeout=void 0,this.secondaryBtnLabel="Try again",this.secondaryBtnIcon="refresh",this.secondaryLabel="Accept connection request in the wallet",this.onConnect=void 0,this.onRender=void 0,this.onAutoConnect=void 0,this.isWalletConnect=!0,this.unsubscribe=[],this.imageSrc=ue.fz.getWalletImage(this.wallet)??ue.fz.getConnectorImage(this.connector),this.name=this.wallet?.name??this.connector?.name??"Wallet",this.isRetrying=!1,this.uri=ue.ConnectionController.state.wcUri,this.error=ue.ConnectionController.state.wcError,this.ready=!1,this.showRetry=!1,this.buffering=!1,this.isMobile=!1,this.onRetry=void 0,this.unsubscribe.push(ue.ConnectionController.subscribeKey("wcUri",n=>{this.uri=n,this.isRetrying&&this.onRetry&&(this.isRetrying=!1,this.onConnect?.())}),ue.ConnectionController.subscribeKey("wcError",n=>this.error=n),ue.ConnectionController.subscribeKey("buffering",n=>this.buffering=n))}firstUpdated(){this.onAutoConnect?.(),this.showRetry=!this.onAutoConnect}disconnectedCallback(){this.unsubscribe.forEach(n=>n()),clearTimeout(this.timeout)}render(){this.onRender?.(),this.onShowRetry();const n=this.error?"Connection can be declined if a previous request is still active":this.secondaryLabel;let e=`Continue in ${this.name}`;return this.buffering&&(e="Connecting..."),this.error&&(e="Connection declined"),Ke.dy`
      <wui-flex
        data-error=${jn(this.error)}
        data-retry=${this.showRetry}
        flexDirection="column"
        alignItems="center"
        .padding=${["3xl","xl","xl","xl"]}
        gap="xl"
      >
        <wui-flex justifyContent="center" alignItems="center">
          <wui-wallet-image size="lg" imageSrc=${jn(this.imageSrc)}></wui-wallet-image>

          ${this.error?null:this.loaderTemplate()}

          <wui-icon-box
            backgroundColor="error-100"
            background="opaque"
            iconColor="error-100"
            icon="close"
            size="sm"
            border
            borderColor="wui-color-bg-125"
          ></wui-icon-box>
        </wui-flex>

        <wui-flex flexDirection="column" alignItems="center" gap="xs">
          <wui-text variant="paragraph-500" color=${this.error?"error-100":"fg-100"}>
            ${e}
          </wui-text>
          <wui-text align="center" variant="small-500" color="fg-200">${n}</wui-text>
        </wui-flex>

        <wui-button
          variant="accent"
          ?disabled=${!this.error&&this.buffering}
          @click=${this.onTryAgain.bind(this)}
        >
          <wui-icon color="inherit" slot="iconLeft" name=${this.secondaryBtnIcon}></wui-icon>
          ${this.secondaryBtnLabel}
        </wui-button>
      </wui-flex>

      ${this.isWalletConnect?Ke.dy`
            <wui-flex .padding=${["0","xl","xl","xl"]} justifyContent="center">
              <wui-link @click=${this.onCopyUri} color="fg-200">
                <wui-icon size="xs" color="fg-200" slot="iconLeft" name="copy"></wui-icon>
                Copy link
              </wui-link>
            </wui-flex>
          `:null}

      <w3m-mobile-download-links .wallet=${this.wallet}></w3m-mobile-download-links>
    `}onShowRetry(){this.error&&!this.showRetry&&(this.showRetry=!0,this.shadowRoot?.querySelector("wui-button")?.animate([{opacity:0},{opacity:1}],{fill:"forwards",easing:"ease"}))}onTryAgain(){this.buffering||(ue.ConnectionController.setWcError(!1),this.onRetry?(this.isRetrying=!0,this.onRetry?.()):this.onConnect?.())}loaderTemplate(){const n=ue.ThemeController.state.themeVariables["--w3m-border-radius-master"],e=n?parseInt(n.replace("px",""),10):4;return Ke.dy`<wui-loading-thumbnail radius=${9*e}></wui-loading-thumbnail>`}onCopyUri(){try{this.uri&&(ue.j1.copyToClopboard(this.uri),ue.SnackController.showSuccess("Link copied"))}catch{ue.SnackController.showError("Failed to copy")}}}Uo.styles=mQe,K4([(0,bt.SB)()],Uo.prototype,"uri",void 0),K4([(0,bt.SB)()],Uo.prototype,"error",void 0),K4([(0,bt.SB)()],Uo.prototype,"ready",void 0),K4([(0,bt.SB)()],Uo.prototype,"showRetry",void 0),K4([(0,bt.SB)()],Uo.prototype,"buffering",void 0),K4([(0,bt.Cb)({type:Boolean})],Uo.prototype,"isMobile",void 0),K4([(0,bt.Cb)()],Uo.prototype,"onRetry",void 0);let See=class extends Uo{constructor(){if(super(),!this.connector)throw new Error("w3m-connecting-view: No connector provided");ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.connector.name??"Unknown",platform:"browser"}}),this.onConnect=this.onConnectProxy.bind(this),this.onAutoConnect=this.onConnectProxy.bind(this),this.isWalletConnect=!1}onConnectProxy(){var n=this;return(0,Ge.Z)(function*(){try{n.error=!1,n.connector&&(n.connector.imageUrl&&ue.MO.setConnectedWalletImageUrl(n.connector.imageUrl),yield ue.ConnectionController.connectExternal(n.connector),ue.OptionsController.state.isSiweEnabled?ue.RouterController.push("ConnectingSiwe"):ue.IN.close(),ue.Xs.sendEvent({type:"track",event:"CONNECT_SUCCESS",properties:{method:"browser",name:n.connector.name||"Unknown"}}))}catch(e){ue.Xs.sendEvent({type:"track",event:"CONNECT_ERROR",properties:{message:e?.message??"Unknown"}}),n.error=!0}})()}};See=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-external-view")],See);var HA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let cy=class extends Ke.oi{constructor(){super(),this.interval=void 0,this.lastRetry=Date.now(),this.wallet=ue.RouterController.state.data?.wallet,this.platform=void 0,this.platforms=[],this.initializeConnection(),this.interval=setInterval(this.initializeConnection.bind(this),ue.bq.TEN_SEC_MS)}disconnectedCallback(){clearTimeout(this.interval)}render(){return this.wallet?(this.determinePlatforms(),Ke.dy`
      ${this.headerTemplate()}
      <div>${this.platformTemplate()}</div>
    `):Ke.dy`<w3m-connecting-wc-qrcode></w3m-connecting-wc-qrcode>`}initializeConnection(n=!1){var e=this;return(0,Ge.Z)(function*(){try{const{wcPairingExpiry:i}=ue.ConnectionController.state;if(n||ue.j1.isPairingExpired(i)){if(ue.ConnectionController.connectWalletConnect(),e.wallet){const r=ue.fz.getWalletImage(e.wallet);r&&ue.MO.setConnectedWalletImageUrl(r)}else{const s=ue.ConnectorController.state.connectors.find(o=>"WALLET_CONNECT"===o.type),a=ue.fz.getConnectorImage(s);a&&ue.MO.setConnectedWalletImageUrl(a)}yield ue.ConnectionController.state.wcPromise,e.finalizeConnection(),ue.OptionsController.state.isSiweEnabled?ue.RouterController.push("ConnectingSiwe"):ue.IN.close()}}catch(i){ue.Xs.sendEvent({type:"track",event:"CONNECT_ERROR",properties:{message:i?.message??"Unknown"}}),ue.ConnectionController.setWcError(!0),ue.j1.isAllowedRetry(e.lastRetry)&&(ue.SnackController.showError("Declined"),e.lastRetry=Date.now(),e.initializeConnection(!0))}})()}finalizeConnection(){const{wcLinking:n,recentWallet:e}=ue.ConnectionController.state;n&&ue.MO.setWalletConnectDeepLink(n),e&&ue.MO.setWeb3ModalRecent(e),ue.Xs.sendEvent({type:"track",event:"CONNECT_SUCCESS",properties:{method:n?"mobile":"qrcode",name:this.wallet?.name||"Unknown"}})}determinePlatforms(){if(!this.wallet)throw new Error("w3m-connecting-wc-view:determinePlatforms No wallet");if(this.platform)return;const{mobile_link:n,desktop_link:e,webapp_link:i,injected:r,rdns:s}=this.wallet,a=r?.map(({injected_id:I})=>I).filter(Boolean),o=s?[s]:a??[],c=o.length,l=n,u=i,d=ue.ConnectionController.checkInstalled(o),h=c&&d,y=e&&!ue.j1.isMobile();h&&this.platforms.push("browser"),l&&this.platforms.push(ue.j1.isMobile()?"mobile":"qrcode"),u&&this.platforms.push("web"),y&&this.platforms.push("desktop"),!h&&c&&this.platforms.push("unsupported"),this.platform=this.platforms[0]}platformTemplate(){switch(this.platform){case"browser":return Ke.dy`<w3m-connecting-wc-browser></w3m-connecting-wc-browser>`;case"desktop":return Ke.dy`
          <w3m-connecting-wc-desktop .onRetry=${()=>this.initializeConnection(!0)}>
          </w3m-connecting-wc-desktop>
        `;case"web":return Ke.dy`
          <w3m-connecting-wc-web .onRetry=${()=>this.initializeConnection(!0)}>
          </w3m-connecting-wc-web>
        `;case"mobile":return Ke.dy`
          <w3m-connecting-wc-mobile isMobile .onRetry=${()=>this.initializeConnection(!0)}>
          </w3m-connecting-wc-mobile>
        `;case"qrcode":return Ke.dy`<w3m-connecting-wc-qrcode></w3m-connecting-wc-qrcode>`;default:return Ke.dy`<w3m-connecting-wc-unsupported></w3m-connecting-wc-unsupported>`}}headerTemplate(){return this.platforms.length>1?Ke.dy`
      <w3m-connecting-header
        .platforms=${this.platforms}
        .onSelectPlatfrom=${this.onSelectPlatform.bind(this)}
      >
      </w3m-connecting-header>
    `:null}onSelectPlatform(n){var e=this;return(0,Ge.Z)(function*(){const i=e.shadowRoot?.querySelector("div");i&&(yield i.animate([{opacity:1},{opacity:0}],{duration:200,fill:"forwards",easing:"ease"}).finished,e.platform=n,i.animate([{opacity:0},{opacity:1}],{duration:200,fill:"forwards",easing:"ease"}))})()}};HA([(0,bt.SB)()],cy.prototype,"platform",void 0),HA([(0,bt.SB)()],cy.prototype,"platforms",void 0),cy=HA([(0,Xt.customElement)("w3m-connecting-wc-view")],cy);let Eee=class extends Ke.oi{constructor(){super(...arguments),this.wallet=ue.RouterController.state.data?.wallet}render(){if(!this.wallet)throw new Error("w3m-downloads-view");return Ke.dy`
      <wui-flex gap="xs" flexDirection="column" .padding=${["s","s","l","s"]}>
        ${this.chromeTemplate()} ${this.iosTemplate()} ${this.androidTemplate()}
        ${this.homepageTemplate()}
      </wui-flex>
    `}chromeTemplate(){return this.wallet?.chrome_store?Ke.dy`<wui-list-item
      variant="icon"
      icon="chromeStore"
      iconVariant="square"
      @click=${this.onChromeStore.bind(this)}
      chevron
    >
      <wui-text variant="paragraph-500" color="fg-100">Chrome Extension</wui-text>
    </wui-list-item>`:null}iosTemplate(){return this.wallet?.app_store?Ke.dy`<wui-list-item
      variant="icon"
      icon="appStore"
      iconVariant="square"
      @click=${this.onAppStore.bind(this)}
      chevron
    >
      <wui-text variant="paragraph-500" color="fg-100">iOS App</wui-text>
    </wui-list-item>`:null}androidTemplate(){return this.wallet?.play_store?Ke.dy`<wui-list-item
      variant="icon"
      icon="playStore"
      iconVariant="square"
      @click=${this.onPlayStore.bind(this)}
      chevron
    >
      <wui-text variant="paragraph-500" color="fg-100">Android App</wui-text>
    </wui-list-item>`:null}homepageTemplate(){return this.wallet?.homepage?Ke.dy`
      <wui-list-item
        variant="icon"
        icon="browser"
        iconVariant="square-blue"
        @click=${this.onHomePage.bind(this)}
        chevron
      >
        <wui-text variant="paragraph-500" color="fg-100">Website</wui-text>
      </wui-list-item>
    `:null}onChromeStore(){this.wallet?.chrome_store&&ue.j1.openHref(this.wallet.chrome_store,"_blank")}onAppStore(){this.wallet?.app_store&&ue.j1.openHref(this.wallet.app_store,"_blank")}onPlayStore(){this.wallet?.play_store&&ue.j1.openHref(this.wallet.play_store,"_blank")}onHomePage(){this.wallet?.homepage&&ue.j1.openHref(this.wallet.homepage,"_blank")}};Eee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-downloads-view")],Eee);let Aee=class extends Ke.oi{render(){return Ke.dy`
      <wui-flex flexDirection="column" padding="s" gap="xs">
        ${this.recommendedWalletsTemplate()}
        <wui-list-wallet
          name="Explore all"
          showAllWallets
          walletIcon="allWallets"
          icon="externalLink"
          @click=${()=>{ue.j1.openHref("https://walletconnect.com/explorer?type=wallet","_blank")}}
        ></wui-list-wallet>
      </wui-flex>
    `}recommendedWalletsTemplate(){const{recommended:n,featured:e}=ue.ApiController.state,{customWallets:i}=ue.OptionsController.state;return[...e,...i??[],...n].slice(0,4).map(s=>Ke.dy`
        <wui-list-wallet
          name=${s.name??"Unknown"}
          tagVariant="main"
          imageSrc=${jn(ue.fz.getWalletImage(s))}
          @click=${()=>{ue.j1.openHref(s.homepage??"https://walletconnect.com/explorer","_blank")}}
        ></wui-list-wallet>
      `)}};Aee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-get-wallet-view")],Aee);const bQe=Ke.iv`
  @keyframes shake {
    0% {
      transform: translateX(0);
    }
    25% {
      transform: translateX(3px);
    }
    50% {
      transform: translateX(-3px);
    }
    75% {
      transform: translateX(3px);
    }
    100% {
      transform: translateX(0);
    }
  }

  wui-flex:first-child:not(:only-child) {
    position: relative;
  }

  wui-loading-hexagon {
    position: absolute;
  }

  wui-icon-box {
    position: absolute;
    right: 4px;
    bottom: 0;
    opacity: 0;
    transform: scale(0.5);
    z-index: 1;
  }

  wui-button {
    display: none;
  }

  [data-error='true'] wui-icon-box {
    opacity: 1;
    transform: scale(1);
  }

  [data-error='true'] > wui-flex:first-child {
    animation: shake 250ms cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
  }

  wui-button[data-retry='true'] {
    display: block;
    opacity: 1;
  }
`;var VA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let zh=class extends Ke.oi{constructor(){super(),this.network=ue.RouterController.state.data?.network,this.unsubscribe=[],this.showRetry=!1,this.error=!1}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}firstUpdated(){this.onSwitchNetwork()}render(){if(!this.network)throw new Error("w3m-network-switch-view: No network provided");this.onShowRetry();const n=this.error?"Switch declined":"Approve in wallet",e=this.error?"Switch can be declined if chain is not supported by a wallet or previous request is still active":"Accept connection request in your wallet";return Ke.dy`
      <wui-flex
        data-error=${this.error}
        flexDirection="column"
        alignItems="center"
        .padding=${["3xl","xl","3xl","xl"]}
        gap="xl"
      >
        <wui-flex justifyContent="center" alignItems="center">
          <wui-network-image
            size="lg"
            imageSrc=${jn(ue.fz.getNetworkImage(this.network))}
          ></wui-network-image>

          ${this.error?null:Ke.dy`<wui-loading-hexagon></wui-loading-hexagon>`}

          <wui-icon-box
            backgroundColor="error-100"
            background="opaque"
            iconColor="error-100"
            icon="close"
            size="sm"
            ?border=${!0}
            borderColor="wui-color-bg-125"
          ></wui-icon-box>
        </wui-flex>

        <wui-flex flexDirection="column" alignItems="center" gap="xs">
          <wui-text align="center" variant="paragraph-500" color="fg-100">${n}</wui-text>
          <wui-text align="center" variant="small-500" color="fg-200">${e}</wui-text>
        </wui-flex>

        <wui-button
          data-retry=${this.showRetry}
          variant="fill"
          .disabled=${!this.error}
          @click=${this.onSwitchNetwork.bind(this)}
        >
          <wui-icon color="inherit" slot="iconLeft" name="refresh"></wui-icon>
          Try again
        </wui-button>
      </wui-flex>
    `}onShowRetry(){this.error&&!this.showRetry&&(this.showRetry=!0,this.shadowRoot?.querySelector("wui-button")?.animate([{opacity:0},{opacity:1}],{fill:"forwards",easing:"ease"}))}onSwitchNetwork(){var n=this;return(0,Ge.Z)(function*(){try{n.error=!1,n.network&&(yield ue.NetworkController.switchActiveNetwork(n.network),ue.OptionsController.state.isSiweEnabled||ue._4.navigateAfterNetworkSwitch())}catch{n.error=!0}})()}};zh.styles=bQe,VA([(0,bt.SB)()],zh.prototype,"showRetry",void 0),VA([(0,bt.SB)()],zh.prototype,"error",void 0),zh=VA([(0,Xt.customElement)("w3m-network-switch-view")],zh);const wQe=Ke.iv`
  :host > wui-grid {
    max-height: 360px;
    overflow: auto;
  }

  wui-grid::-webkit-scrollbar {
    display: none;
  }
`;var Iee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let ly=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.caipNetwork=ue.NetworkController.state.caipNetwork,this.unsubscribe.push(ue.NetworkController.subscribeKey("caipNetwork",n=>this.caipNetwork=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-grid padding="s" gridTemplateColumns="repeat(4, 1fr)" rowGap="l" columnGap="xs">
        ${this.networksTemplate()}
      </wui-grid>

      <wui-separator></wui-separator>

      <wui-flex padding="s" flexDirection="column" gap="m" alignItems="center">
        <wui-text variant="small-400" color="fg-300" align="center">
          Your connected wallet may not support some of the networks available for this dApp
        </wui-text>
        <wui-link @click=${this.onNetworkHelp.bind(this)}>
          <wui-icon size="xs" color="accent-100" slot="iconLeft" name="helpCircle"></wui-icon>
          What is a network
        </wui-link>
      </wui-flex>
    `}onNetworkHelp(){ue.Xs.sendEvent({type:"track",event:"CLICK_NETWORK_HELP"}),ue.RouterController.push("WhatIsANetwork")}networksTemplate(){const{approvedCaipNetworkIds:n,requestedCaipNetworks:e,supportsAllNetworks:i}=ue.NetworkController.state;return ue.j1.sortRequestedNetworks(n,e)?.map(s=>Ke.dy`
        <wui-card-select
          .selected=${this.caipNetwork?.id===s.id}
          imageSrc=${jn(ue.fz.getNetworkImage(s))}
          type="network"
          name=${s.name??s.id}
          @click=${()=>this.onSwitchNetwork(s)}
          .disabled=${!i&&!n?.includes(s.id)}
          data-testid=${`w3m-network-switch-${s.name??s.id}`}
        ></wui-card-select>
      `)}onSwitchNetwork(n){return(0,Ge.Z)(function*(){const{isConnected:e}=ue.AccountController.state,{approvedCaipNetworkIds:i,supportsAllNetworks:r,caipNetwork:s}=ue.NetworkController.state,{data:a}=ue.RouterController.state;e&&s?.id!==n.id?i?.includes(n.id)?(yield ue.NetworkController.switchActiveNetwork(n),ue._4.navigateAfterNetworkSwitch()):r&&ue.RouterController.push("SwitchNetwork",{...a,network:n}):e||(ue.NetworkController.setCaipNetwork(n),ue.RouterController.push("Connect"))})()}};ly.styles=wQe,Iee([(0,bt.SB)()],ly.prototype,"caipNetwork",void 0),ly=Iee([(0,Xt.customElement)("w3m-networks-view")],ly);var Dc=$(4144);const CQe=Ke.iv`
  :host > wui-flex {
    height: 500px;
    overflow-y: auto;
    overflow-x: hidden;
    scrollbar-width: none;
    padding: var(--wui-spacing-m);
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: flex-start;
  }

  :host > wui-flex > wui-flex {
    width: 100%;
  }

  wui-transaction-list-item-loader {
    width: 100%;
  }
`;var Oh=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let X4=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.refetchTimeout=void 0,this.selectedOnRampProvider=ue.ph.state.selectedProvider,this.loading=!1,this.coinbaseTransactions=ue.sl.state.coinbaseTransactions,this.tokenImages=ue.WM.state.tokenImages,this.unsubscribe.push(ue.ph.subscribeKey("selectedProvider",n=>{this.selectedOnRampProvider=n}),ue.WM.subscribeKey("tokenImages",n=>this.tokenImages=n),()=>{clearTimeout(this.refetchTimeout)},ue.sl.subscribe(n=>{this.coinbaseTransactions={...n.coinbaseTransactions}})),ue.sl.clearCursor(),this.fetchTransactions()}render(){return Ke.dy`
      <wui-flex flexDirection="column" padding="s" gap="xs">
        ${this.loading?this.templateLoading():this.templateTransactionsByYear()}
      </wui-flex>
    `}templateTransactions(n){return n?.map(e=>{const i=Dc.Em.formatDate(e?.metadata?.minedAt),r=e.transfers[0],s=r?.fungible_info;if(!s)return null;const a=s?.icon?.url||this.tokenImages?.[s.symbol||""];return Ke.dy`
        <wui-onramp-activity-item
          label="Bought"
          .completed=${"ONRAMP_TRANSACTION_STATUS_SUCCESS"===e.metadata.status}
          .inProgress=${"ONRAMP_TRANSACTION_STATUS_IN_PROGRESS"===e.metadata.status}
          .failed=${"ONRAMP_TRANSACTION_STATUS_FAILED"===e.metadata.status}
          purchaseCurrency=${jn(s.symbol)}
          purchaseValue=${r.quantity.numeric}
          date=${i}
          icon=${jn(a)}
          symbol=${jn(s.symbol)}
        ></wui-onramp-activity-item>
      `})}templateTransactionsByYear(){return Object.keys(this.coinbaseTransactions).sort().reverse().map(e=>{const i=parseInt(e,10);return new Array(12).fill(null).map((s,a)=>a).reverse().map(s=>{const a=Xt.TransactionUtil.getTransactionGroupTitle(i,s),o=this.coinbaseTransactions[i]?.[s];return o?Ke.dy`
          <wui-flex flexDirection="column">
            <wui-flex
              alignItems="center"
              flexDirection="row"
              .padding=${["xs","s","s","s"]}
            >
              <wui-text variant="paragraph-500" color="fg-200">${a}</wui-text>
            </wui-flex>
            <wui-flex flexDirection="column" gap="xs">
              ${this.templateTransactions(o)}
            </wui-flex>
          </wui-flex>
        `:null})})}fetchTransactions(){var n=this;return(0,Ge.Z)(function*(){yield n.fetchCoinbaseTransactions()})()}fetchCoinbaseTransactions(){var n=this;return(0,Ge.Z)(function*(){const e=ue.AccountController.state.address,i=ue.OptionsController.state.projectId;if(!e)throw new Error("No address found");if(!i)throw new Error("No projectId found");n.loading=!0,yield ue.sl.fetchTransactions(e,"coinbase"),n.loading=!1,n.refetchLoadingTransactions()})()}refetchLoadingTransactions(){var n=this;const e=new Date;0!==(this.coinbaseTransactions[e.getFullYear()]?.[e.getMonth()]||[]).filter(s=>"ONRAMP_TRANSACTION_STATUS_IN_PROGRESS"===s.metadata.status).length?this.refetchTimeout=setTimeout((0,Ge.Z)(function*(){const s=ue.AccountController.state.address;yield ue.sl.fetchTransactions(s,"coinbase"),n.refetchLoadingTransactions()}),3e3):clearTimeout(this.refetchTimeout)}templateLoading(){return Array(7).fill(Ke.dy` <wui-transaction-list-item-loader></wui-transaction-list-item-loader> `).map(n=>n)}};X4.styles=CQe,Oh([(0,bt.SB)()],X4.prototype,"selectedOnRampProvider",void 0),Oh([(0,bt.SB)()],X4.prototype,"loading",void 0),Oh([(0,bt.SB)()],X4.prototype,"coinbaseTransactions",void 0),Oh([(0,bt.SB)()],X4.prototype,"tokenImages",void 0),X4=Oh([(0,Xt.customElement)("w3m-onramp-activity-view")],X4);const TQe=Ke.iv`
  :host > wui-grid {
    max-height: 360px;
    overflow: auto;
  }

  wui-grid::-webkit-scrollbar {
    display: none;
  }
`;var uy=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Dd=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.selectedCurrency=ue.ph.state.paymentCurrency,this.currencies=ue.ph.state.paymentCurrencies,this.currencyImages=ue.WM.state.currencyImages,this.unsubscribe.push(ue.ph.subscribe(n=>{this.selectedCurrency=n.paymentCurrency,this.currencies=n.paymentCurrencies}),ue.WM.subscribeKey("currencyImages",n=>this.currencyImages=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-flex flexDirection="column" padding="s" gap="xs">
        ${this.currenciesTemplate()}
      </wui-flex>
      <w3m-legal-footer></w3m-legal-footer>
    `}currenciesTemplate(){return this.currencies.map(n=>Ke.dy`
        <wui-list-item
          imageSrc=${jn(this.currencyImages?.[n.id])}
          @click=${()=>this.selectCurrency(n)}
          variant="image"
        >
          <wui-text variant="paragraph-500" color="fg-100">${n.id}</wui-text>
        </wui-list-item>
      `)}selectCurrency(n){n&&(ue.ph.setPaymentCurrency(n),ue.IN.close())}};Dd.styles=TQe,uy([(0,bt.SB)()],Dd.prototype,"selectedCurrency",void 0),uy([(0,bt.SB)()],Dd.prototype,"currencies",void 0),uy([(0,bt.SB)()],Dd.prototype,"currencyImages",void 0),Dd=uy([(0,Xt.customElement)("w3m-onramp-fiat-select-view")],Dd);var Dee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let FA=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.providers=ue.ph.state.providers,this.unsubscribe.push(ue.ph.subscribeKey("providers",n=>{this.providers=n}))}firstUpdated(){var n=this;const e=this.providers.map(function(){var i=(0,Ge.Z)(function*(r){return"coinbase"===r.name?yield n.getCoinbaseOnRampURL():Promise.resolve(r?.url)});return function(r){return i.apply(this,arguments)}}());Promise.all(e).then(i=>{this.providers=this.providers.map((r,s)=>({...r,url:i[s]||""}))})}render(){return Ke.dy`
      <wui-flex flexDirection="column" padding="s" gap="xs">
        ${this.onRampProvidersTemplate()}
      </wui-flex>
      <w3m-onramp-providers-footer></w3m-onramp-providers-footer>
    `}onRampProvidersTemplate(){return this.providers.map(n=>Ke.dy`
        <wui-onramp-provider-item
          label=${n.label}
          name=${n.name}
          feeRange=${n.feeRange}
          @click=${()=>{this.onClickProvider(n)}}
          ?disabled=${!n.url}
        ></wui-onramp-provider-item>
      `)}onClickProvider(n){ue.ph.setSelectedProvider(n),ue.RouterController.push("BuyInProgress"),ue.j1.openHref(n.url,"popupWindow","width=600,height=800,scrollbars=yes")}getCoinbaseOnRampURL(){return(0,Ge.Z)(function*(){const n=ue.AccountController.state.address,e=ue.NetworkController.state.caipNetwork;if(!n)throw new Error("No address found");if(!e?.name)throw new Error("No network found");const i=ue.bq.WC_COINBASE_PAY_SDK_CHAIN_NAME_MAP[e.name]??ue.bq.WC_COINBASE_PAY_SDK_FALLBACK_CHAIN,r=ue.ph.state.purchaseCurrency,s=r?[r.symbol]:ue.ph.state.purchaseCurrencies.map(a=>a.symbol);return yield ue.Lr.generateOnRampURL({defaultNetwork:i,destinationWallets:[{address:n,blockchains:ue.bq.WC_COINBASE_PAY_SDK_CHAINS,assets:s}],partnerUserId:n,purchaseAmount:ue.ph.state.purchaseAmount})})()}};Dee([(0,bt.SB)()],FA.prototype,"providers",void 0),FA=Dee([(0,Xt.customElement)("w3m-onramp-providers-view")],FA);const MQe=Ke.iv`
  :host > wui-grid {
    max-height: 360px;
    overflow: auto;
  }

  wui-grid::-webkit-scrollbar {
    display: none;
  }
`;var dy=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Nd=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.selectedCurrency=ue.ph.state.purchaseCurrencies,this.tokens=ue.ph.state.purchaseCurrencies,this.tokenImages=ue.WM.state.tokenImages,this.unsubscribe.push(ue.ph.subscribe(n=>{this.selectedCurrency=n.purchaseCurrencies,this.tokens=n.purchaseCurrencies}),ue.WM.subscribeKey("tokenImages",n=>this.tokenImages=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-flex flexDirection="column" padding="s" gap="xs">
        ${this.currenciesTemplate()}
      </wui-flex>
      <w3m-legal-footer></w3m-legal-footer>
    `}currenciesTemplate(){return this.tokens.map(n=>Ke.dy`
        <wui-list-item
          imageSrc=${jn(this.tokenImages?.[n.symbol])}
          @click=${()=>this.selectToken(n)}
          variant="image"
        >
          <wui-flex gap="3xs" alignItems="center">
            <wui-text variant="paragraph-500" color="fg-100">${n.name}</wui-text>
            <wui-text variant="small-400" color="fg-200">${n.symbol}</wui-text>
          </wui-flex>
        </wui-list-item>
      `)}selectToken(n){n&&(ue.ph.setPurchaseCurrency(n),ue.IN.close())}};Nd.styles=MQe,dy([(0,bt.SB)()],Nd.prototype,"selectedCurrency",void 0),dy([(0,bt.SB)()],Nd.prototype,"tokens",void 0),dy([(0,bt.SB)()],Nd.prototype,"tokenImages",void 0),Nd=dy([(0,Xt.customElement)("w3m-onramp-token-select-view")],Nd);const kQe=Ke.iv`
  :host > wui-flex:first-child {
    height: 500px;
    overflow-y: auto;
    overflow-x: hidden;
    scrollbar-width: none;
    padding: var(--wui-spacing-m);
  }

  :host > wui-flex:first-child::-webkit-scrollbar {
    display: none;
  }
`;let BA=class extends Ke.oi{render(){return Ke.dy`
      <wui-flex flexDirection="column" gap="s">
        <w3m-activity-list page="activity"></w3m-activity-list>
      </wui-flex>
    `}};BA.styles=kQe,BA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-transactions-view")],BA);const AQe=[{images:["network","layers","system"],title:"The system\u2019s nuts and bolts",text:"A network is what brings the blockchain to life, as this technical infrastructure allows apps to access the ledger and smart contract services."},{images:["noun","defiAlt","dao"],title:"Designed for different uses",text:"Each network is designed differently, and may therefore suit certain apps and experiences."}];let Nee=class extends Ke.oi{render(){return Ke.dy`
      <wui-flex
        flexDirection="column"
        .padding=${["xxl","xl","xl","xl"]}
        alignItems="center"
        gap="xl"
      >
        <w3m-help-widget .data=${AQe}></w3m-help-widget>
        <wui-button
          variant="fill"
          size="sm"
          @click=${()=>{ue.j1.openHref("https://ethereum.org/en/developers/docs/networks/","_blank")}}
        >
          Learn more
          <wui-icon color="inherit" slot="iconRight" name="externalLink"></wui-icon>
        </wui-button>
      </wui-flex>
    `}};Nee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-what-is-a-network-view")],Nee);const DQe=[{images:["login","profile","lock"],title:"One login for all of web3",text:"Log in to any app by connecting your wallet. Say goodbye to countless passwords!"},{images:["defi","nft","eth"],title:"A home for your digital assets",text:"A wallet lets you store, send and receive digital assets like cryptocurrencies and NFTs."},{images:["browser","noun","dao"],title:"Your gateway to a new web",text:"With your wallet, you can explore and interact with DeFi, NFTs, DAOs, and much more."}];let Ree=class extends Ke.oi{render(){return Ke.dy`
      <wui-flex
        flexDirection="column"
        .padding=${["xxl","xl","xl","xl"]}
        alignItems="center"
        gap="xl"
      >
        <w3m-help-widget .data=${DQe}></w3m-help-widget>
        <wui-button variant="fill" size="sm" @click=${this.onGetWallet.bind(this)}>
          <wui-icon color="inherit" slot="iconLeft" name="wallet"></wui-icon>
          Get a wallet
        </wui-button>
      </wui-flex>
    `}onGetWallet(){ue.Xs.sendEvent({type:"track",event:"CLICK_GET_WALLET"}),ue.RouterController.push("GetWallet")}};Ree=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-what-is-a-wallet-view")],Ree);let Lee=class extends Ke.oi{render(){return Ke.dy`
      <wui-flex
        flexDirection="column"
        .padding=${["xxl","3xl","xl","3xl"]}
        alignItems="center"
        gap="xl"
      >
        <wui-visual name="onrampCard"></wui-visual>
        <wui-flex flexDirection="column" gap="xs" alignItems="center">
          <wui-text align="center" variant="paragraph-500" color="fg-100">
            Quickly and easily buy digital assets!
          </wui-text>
          <wui-text align="center" variant="small-400" color="fg-200">
            Simply select your preferred onramp provider and add digital assets to your account
            using your credit card or bank transfer
          </wui-text>
        </wui-flex>
        <wui-button @click=${ue.RouterController.goBack}>
          <wui-icon size="sm" color="inherit" name="add" slot="iconLeft"></wui-icon>
          Buy
        </wui-button>
      </wui-flex>
    `}};Lee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-what-is-a-buy-view")],Lee);const RQe=Ke.iv`
  wui-loading-spinner {
    margin: 9px auto;
  }
`;var fy=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Pl=class extends Ke.oi{firstUpdated(){this.startOTPTimeout()}disconnectedCallback(){clearTimeout(this.OTPTimeout)}constructor(){super(),this.loading=!1,this.timeoutTimeLeft=es.getTimeToNextEmailLogin(),this.error="",this.otp="",this.email=ue.RouterController.state.data?.email,this.emailConnector=ue.ConnectorController.getEmailConnector()}render(){if(!this.email)throw new Error("w3m-email-otp-widget: No email provided");const n=!!this.timeoutTimeLeft,e=this.getFooterLabels(n);return Ke.dy`
      <wui-flex
        flexDirection="column"
        alignItems="center"
        .padding=${["l","0","l","0"]}
        gap="l"
      >
        <wui-flex flexDirection="column" alignItems="center">
          <wui-text variant="paragraph-400" color="fg-100">Enter the code we sent to</wui-text>
          <wui-text variant="paragraph-500" color="fg-100">${this.email}</wui-text>
        </wui-flex>

        <wui-text variant="small-400" color="fg-200">The code expires in 20 minutes</wui-text>

        ${this.loading?Ke.dy`<wui-loading-spinner size="xl" color="accent-100"></wui-loading-spinner>`:Ke.dy` <wui-flex flexDirection="column" alignItems="center" gap="xs">
              <wui-otp
                dissabled
                length="6"
                @inputChange=${this.onOtpInputChange.bind(this)}
                .otp=${this.otp}
              ></wui-otp>
              ${this.error?Ke.dy`
                    <wui-text variant="small-400" align="center" color="error-100">
                      ${this.error}. Try Again
                    </wui-text>
                  `:null}
            </wui-flex>`}

        <wui-flex alignItems="center">
          <wui-text variant="small-400" color="fg-200">${e.title}</wui-text>
          <wui-link @click=${this.onResendCode.bind(this)} .disabled=${n}>
            ${e.action}
          </wui-link>
        </wui-flex>
      </wui-flex>
    `}startOTPTimeout(){this.timeoutTimeLeft=es.getTimeToNextEmailLogin(),this.OTPTimeout=setInterval(()=>{this.timeoutTimeLeft>0?this.timeoutTimeLeft=es.getTimeToNextEmailLogin():clearInterval(this.OTPTimeout)},1e3)}onOtpInputChange(n){var e=this;return(0,Ge.Z)(function*(){try{e.loading||(e.otp=n.detail,e.emailConnector&&6===e.otp.length&&(e.loading=!0,yield e.onOtpSubmit?.(e.otp)))}catch(i){e.error=ue.j1.parseError(i),e.loading=!1}})()}onResendCode(){var n=this;return(0,Ge.Z)(function*(){try{if(n.onOtpResend){if(!n.loading&&!n.timeoutTimeLeft){if(n.error="",n.otp="",!ue.ConnectorController.getEmailConnector()||!n.email)throw new Error("w3m-email-otp-widget: Unable to resend email");n.loading=!0,yield n.onOtpResend(n.email),n.startOTPTimeout(),ue.SnackController.showSuccess("Code email resent")}}else n.onStartOver&&n.onStartOver()}catch(e){ue.SnackController.showError(e)}finally{n.loading=!1}})()}getFooterLabels(n){return this.onStartOver?{title:"Something wrong?",action:"Try again "+(n?`in ${this.timeoutTimeLeft}s`:"")}:{title:"Didn't receive it?",action:"Resend "+(n?`in ${this.timeoutTimeLeft}s`:"Code")}}};Pl.styles=RQe,fy([(0,bt.SB)()],Pl.prototype,"loading",void 0),fy([(0,bt.SB)()],Pl.prototype,"timeoutTimeLeft",void 0),fy([(0,bt.SB)()],Pl.prototype,"error",void 0),Pl=fy([(0,Xt.customElement)("w3m-email-otp-widget")],Pl);var Pee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let UA=class extends Pl{constructor(){var n;super(),n=this,this.unsubscribe=[],this.smartAccountDeployed=ue.AccountController.state.smartAccountDeployed,this.onOtpSubmit=function(){var e=(0,Ge.Z)(function*(i){try{if(n.emailConnector){const r=ue.NetworkController.checkIfSmartAccountEnabled();yield n.emailConnector.provider.connectOtp({otp:i}),ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_PASS"}),yield ue.ConnectionController.connectExternal(n.emailConnector),ue.Xs.sendEvent({type:"track",event:"CONNECT_SUCCESS",properties:{method:"email",name:n.emailConnector.name||"Unknown"}}),r&&!n.smartAccountDeployed?ue.RouterController.push("UpgradeToSmartAccount"):ue.IN.close()}}catch(r){throw ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_FAIL"}),r}});return function(i){return e.apply(this,arguments)}}(),this.onOtpResend=function(){var e=(0,Ge.Z)(function*(i){n.emailConnector&&(yield n.emailConnector.provider.connectEmail({email:i}),ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_SENT"}))});return function(i){return e.apply(this,arguments)}}(),this.unsubscribe.push(ue.AccountController.subscribeKey("smartAccountDeployed",e=>{this.smartAccountDeployed=e}))}};Pee([(0,bt.SB)()],UA.prototype,"smartAccountDeployed",void 0),UA=Pee([(0,Xt.customElement)("w3m-email-verify-otp-view")],UA);const PQe=Ke.iv`
  wui-icon-box {
    height: var(--wui-icon-box-size-xl);
    width: var(--wui-icon-box-size-xl);
  }
`;var zee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let hy=class extends Ke.oi{constructor(){super(),this.email=ue.RouterController.state.data?.email,this.emailConnector=ue.ConnectorController.getEmailConnector(),this.loading=!1,this.listenForDeviceApproval()}render(){if(!this.email)throw new Error("w3m-email-verify-device-view: No email provided");if(!this.emailConnector)throw new Error("w3m-email-verify-device-view: No email connector provided");return Ke.dy`
      <wui-flex
        flexDirection="column"
        alignItems="center"
        .padding=${["xxl","s","xxl","s"]}
        gap="l"
      >
        <wui-icon-box
          size="xl"
          iconcolor="accent-100"
          backgroundcolor="accent-100"
          icon="verify"
          background="opaque"
        ></wui-icon-box>

        <wui-flex flexDirection="column" alignItems="center" gap="s">
          <wui-flex flexDirection="column" alignItems="center">
            <wui-text variant="paragraph-400" color="fg-100">
              Approve the login link we sent to
            </wui-text>
            <wui-text variant="paragraph-400" color="fg-100"><b>${this.email}</b></wui-text>
          </wui-flex>

          <wui-text variant="small-400" color="fg-200" align="center">
            The code expires in 20 minutes
          </wui-text>

          <wui-flex alignItems="center" id="w3m-resend-section">
            <wui-text variant="small-400" color="fg-100" align="center">
              Didn't receive it?
            </wui-text>
            <wui-link @click=${this.onResendCode.bind(this)} .disabled=${this.loading}>
              Resend email
            </wui-link>
          </wui-flex>
        </wui-flex>
      </wui-flex>
    `}listenForDeviceApproval(){var n=this;return(0,Ge.Z)(function*(){if(n.emailConnector)try{yield n.emailConnector.provider.connectDevice(),ue.Xs.sendEvent({type:"track",event:"DEVICE_REGISTERED_FOR_EMAIL"}),ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_SENT"}),ue.RouterController.replace("EmailVerifyOtp",{email:n.email})}catch{ue.RouterController.goBack()}})()}onResendCode(){var n=this;return(0,Ge.Z)(function*(){try{if(!n.loading){if(!n.emailConnector||!n.email)throw new Error("w3m-email-login-widget: Unable to resend email");n.loading=!0,yield n.emailConnector.provider.connectEmail({email:n.email}),n.listenForDeviceApproval(),ue.SnackController.showSuccess("Code email resent")}}catch(e){ue.SnackController.showError(e)}finally{n.loading=!1}})()}};hy.styles=PQe,zee([(0,bt.SB)()],hy.prototype,"loading",void 0),hy=zee([(0,Xt.customElement)("w3m-email-verify-device-view")],hy);const zQe=Ke.iv`
  div {
    width: 100%;
    height: 400px;
  }

  [data-ready='false'] {
    transform: scale(1.05);
  }

  @media (max-width: 430px) {
    [data-ready='false'] {
      transform: translateY(-50px);
    }
  }
`;var Oee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let py=class extends Ke.oi{constructor(){super(),this.bodyObserver=void 0,this.unsubscribe=[],this.iframe=document.getElementById("w3m-iframe"),this.ready=!1,this.unsubscribe.push(ue.IN.subscribeKey("open",n=>{n||this.onHideIframe()}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n()),this.bodyObserver?.unobserve(window.document.body)}firstUpdated(){var n=this;return(0,Ge.Z)(function*(){yield n.syncTheme(),n.iframe.style.display="block";const i=n.renderRoot.querySelector("div");n.bodyObserver=new ResizeObserver(()=>{const s=i?.getBoundingClientRect()??{left:0,top:0,width:0,height:0};n.iframe.style.width="360px",n.iframe.style.height=s.height-10+"px",n.iframe.style.left="calc(50% - 180px)",n.iframe.style.top=`${s.top+5}px`,n.ready=!0}),n.bodyObserver.observe(window.document.body)})()}render(){return this.ready&&this.onShowIframe(),Ke.dy`<div data-ready=${this.ready}></div>`}onShowIframe(){const n=window.innerWidth<=430;this.iframe.animate([{opacity:0,transform:n?"translateY(50px)":"scale(.95)"},{opacity:1,transform:n?"translateY(0)":"scale(1)"}],{duration:200,easing:"ease",fill:"forwards"})}onHideIframe(){var n=this;return(0,Ge.Z)(function*(){yield n.iframe.animate([{opacity:1},{opacity:0}],{duration:200,easing:"ease",fill:"forwards"}).finished,n.iframe.style.display="none"})()}syncTheme(){return(0,Ge.Z)(function*(){const n=ue.ConnectorController.getEmailConnector();n&&(yield n.provider.syncTheme({themeVariables:ue.ThemeController.getSnapshot().themeVariables}))})()}};py.styles=zQe,Oee([(0,bt.SB)()],py.prototype,"ready",void 0),py=Oee([(0,Xt.customElement)("w3m-approve-transaction-view")],py);let Hee=class extends Ke.oi{render(){return Ke.dy`
      <wui-flex flexDirection="column" alignItems="center" gap="xl" padding="xl">
        <wui-text variant="paragraph-400" color="fg-100">Follow the instructions on</wui-text>
        <wui-chip
          icon="externalLink"
          variant="fill"
          href=${ue.bq.SECURE_SITE_DASHBOARD}
          imageSrc=${ue.bq.SECURE_SITE_FAVICON}
          data-testid="w3m-secure-website-button"
        >
        </wui-chip>
        <wui-text variant="small-400" color="fg-200">
          You will have to reconnect for security reasons
        </wui-text>
      </wui-flex>
    `}};Hee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-upgrade-wallet-view")],Hee);var $A=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let my=class extends Ke.oi{constructor(){var n;super(...arguments),n=this,this.emailConnector=ue.ConnectorController.getEmailConnector(),this.loading=!1,this.setPreferSmartAccount=(0,Ge.Z)(function*(){if(n.emailConnector)try{n.loading=!0,yield n.emailConnector.provider.setPreferredAccount(wa.ACCOUNT_TYPES.SMART_ACCOUNT),yield n.emailConnector.provider.connect({preferredAccountType:wa.ACCOUNT_TYPES.SMART_ACCOUNT}),n.loading=!1,ue.RouterController.push("Account")}catch{ue.SnackController.showError("Error upgrading to smart account")}})}render(){return Ke.dy`
      <wui-flex
        flexDirection="column"
        alignItems="center"
        gap="xxl"
        .padding=${["0","0","l","0"]}
      >
        ${this.onboardingTemplate()} ${this.buttonsTemplate()}
        <wui-link>
          Learn more
          <wui-icon color="inherit" slot="iconRight" name="externalLink"></wui-icon>
        </wui-link>
      </wui-flex>
    `}onboardingTemplate(){return Ke.dy` <wui-flex
      flexDirection="column"
      gap="xxl"
      alignItems="center"
      .padding=${["0","xxl","0","xxl"]}
    >
      <wui-flex gap="s" alignItems="center" justifyContent="center">
        <wui-visual name="google"></wui-visual>
        <wui-visual name="pencil"></wui-visual>
        <wui-visual name="lightbulb"></wui-visual>
      </wui-flex>
      <wui-flex flexDirection="column" alignItems="center" gap="s">
        <wui-text align="center" variant="medium-600" color="fg-100">
          Discover Smart Accounts
        </wui-text>
        <wui-text align="center" variant="paragraph-400" color="fg-100">
          Access advanced features such as username, social login, improved security and a smoother
          user experience!
        </wui-text>
      </wui-flex>
    </wui-flex>`}buttonsTemplate(){return Ke.dy`<wui-flex .padding=${["0","2l","0","2l"]} gap="s">
      <wui-button
        variant="accentBg"
        @click=${this.redirectToAccount.bind(this)}
        size="lg"
        borderRadius="xs"
      >
        Do it later
      </wui-button>
      <wui-button
        .loading=${this.loading}
        size="lg"
        borderRadius="xs"
        @click=${this.setPreferSmartAccount.bind(this)}
        >Continue
      </wui-button>
    </wui-flex>`}redirectToAccount(){ue.RouterController.push("Account")}};$A([(0,bt.SB)()],my.prototype,"emailConnector",void 0),$A([(0,bt.SB)()],my.prototype,"loading",void 0),my=$A([(0,Xt.customElement)("w3m-upgrade-to-smart-account-view")],my);class $Qe{constructor(n){}get _$AU(){return this._$AM._$AU}_$AT(n,e,i){this._$Ct=n,this._$AM=e,this._$Ci=i}_$AS(n,e){return this.update(n,e)}update(n,e){return this.render(...e)}}const Hh=(t,n)=>{const e=t._$AN;if(void 0===e)return!1;for(const i of e)i._$AO?.(n,!1),Hh(i,n);return!0},gy=t=>{let n,e;do{if(void 0===(n=t._$AM))break;e=n._$AN,e.delete(t),t=n}while(0===e?.size)},Fee=t=>{for(let n;n=t._$AM;t=n){let e=n._$AN;if(void 0===e)n._$AN=e=new Set;else if(e.has(t))break;e.add(t),qQe(n)}};function jQe(t){void 0!==this._$AN?(gy(this),this._$AM=t,Fee(this)):this._$AM=t}function WQe(t,n=!1,e=0){const i=this._$AH,r=this._$AN;if(void 0!==r&&0!==r.size)if(n)if(Array.isArray(i))for(let s=e;s<i.length;s++)Hh(i[s],!1),gy(i[s]);else null!=i&&(Hh(i,!1),gy(i));else Hh(this,t)}const qQe=t=>{2==t.type&&(t._$AP??=WQe,t._$AQ??=jQe)};class GQe extends $Qe{constructor(){super(...arguments),this._$AN=void 0}_$AT(n,e,i){super._$AT(n,e,i),Fee(this),this.isConnected=n._$AU}_$AO(n,e=!0){n!==this.isConnected&&(this.isConnected=n,n?this.reconnected?.():this.disconnected?.()),e&&(Hh(this,n),gy(this))}setValue(n){if((t=>void 0===this._$Ct.strings)())this._$Ct._$AI(n,this);else{const e=[...this._$Ct._$AH];e[this._$Ci]=n,this._$Ct._$AI(e,this,0)}}disconnected(){}reconnected(){}}const vy=()=>new ZQe;class ZQe{}const jA=new WeakMap,yy=(t=>(...n)=>({_$litDirective$:t,values:n}))(class extends GQe{render(t){return Yv.Ld}update(t,[n]){const e=n!==this.Y;return e&&void 0!==this.Y&&this.rt(void 0),(e||this.lt!==this.ct)&&(this.Y=n,this.ht=t.options?.host,this.rt(this.ct=t.element)),Yv.Ld}rt(t){if("function"==typeof this.Y){const n=this.ht??globalThis;let e=jA.get(n);void 0===e&&(e=new WeakMap,jA.set(n,e)),void 0!==e.get(this.Y)&&this.Y.call(this.ht,void 0),e.set(this.Y,t),void 0!==t&&this.Y.call(this.ht,t)}else this.Y.value=t}get lt(){return"function"==typeof this.Y?jA.get(this.ht??globalThis)?.get(this.Y):this.Y?.value}disconnected(){this.lt===this.ct&&this.rt(void 0)}reconnected(){this.rt(this.ct)}}),YQe=Ke.iv`
  wui-email-input {
    width: 100%;
  }

  form {
    width: 100%;
    display: block;
    position: relative;
  }
`;var WA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Vh=class extends Ke.oi{constructor(){super(...arguments),this.formRef=vy(),this.initialEmail=ue.RouterController.state.data?.email??"",this.email="",this.loading=!1}firstUpdated(){this.formRef.value?.addEventListener("keydown",n=>{"Enter"===n.key&&this.onSubmitEmail(n)})}render(){const n=!this.loading&&this.email.length>3&&this.email!==this.initialEmail;return Ke.dy`
      <wui-flex flexDirection="column" padding="m" gap="m">
        <form ${yy(this.formRef)} @submit=${this.onSubmitEmail.bind(this)}>
          <wui-email-input
            value=${this.initialEmail}
            .disabled=${this.loading}
            @inputChange=${this.onEmailInputChange.bind(this)}
          >
          </wui-email-input>
          <input type="submit" hidden />
        </form>

        <wui-flex gap="s">
          <wui-button size="md" variant="shade" fullWidth @click=${ue.RouterController.goBack}>
            Cancel
          </wui-button>

          <wui-button
            size="md"
            variant="fill"
            fullWidth
            @click=${this.onSubmitEmail.bind(this)}
            .disabled=${!n}
            .loading=${this.loading}
          >
            Save
          </wui-button>
        </wui-flex>
      </wui-flex>
    `}onEmailInputChange(n){this.email=n.detail}onSubmitEmail(n){var e=this;return(0,Ge.Z)(function*(){try{if(e.loading)return;e.loading=!0,n.preventDefault();const i=ue.ConnectorController.getEmailConnector();if(!i)throw new Error("w3m-update-email-wallet: Email connector not found");yield i.provider.updateEmail({email:e.email}),ue.Xs.sendEvent({type:"track",event:"EMAIL_EDIT"}),ue.RouterController.replace("UpdateEmailPrimaryOtp",{email:e.initialEmail,newEmail:e.email})}catch(i){ue.SnackController.showError(i),e.loading=!1}})()}};Vh.styles=YQe,WA([(0,bt.SB)()],Vh.prototype,"email",void 0),WA([(0,bt.SB)()],Vh.prototype,"loading",void 0),Vh=WA([(0,Xt.customElement)("w3m-update-email-wallet-view")],Vh);let Bee=class extends Pl{constructor(){var n;super(),n=this,this.email=ue.RouterController.state.data?.email,this.onOtpSubmit=function(){var e=(0,Ge.Z)(function*(i){try{n.emailConnector&&(yield n.emailConnector.provider.updateEmailPrimaryOtp({otp:i}),ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_PASS"}),ue.RouterController.replace("UpdateEmailSecondaryOtp",ue.RouterController.state.data))}catch(r){throw ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_FAIL"}),r}});return function(i){return e.apply(this,arguments)}}(),this.onStartOver=()=>{ue.RouterController.replace("UpdateEmailWallet",ue.RouterController.state.data)}}};Bee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-update-email-primary-otp-view")],Bee);let Uee=class extends Pl{constructor(){var n;super(),n=this,this.email=ue.RouterController.state.data?.newEmail,this.onOtpSubmit=function(){var e=(0,Ge.Z)(function*(i){try{n.emailConnector&&(yield n.emailConnector.provider.updateEmailSecondaryOtp({otp:i}),ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_PASS"}),ue.RouterController.reset("Account"))}catch(r){throw ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_FAIL"}),r}});return function(i){return e.apply(this,arguments)}}(),this.onStartOver=()=>{ue.RouterController.replace("UpdateEmailWallet",ue.RouterController.state.data)}}};Uee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-update-email-secondary-otp-view")],Uee);const QQe=Ke.iv`
  :host > wui-flex {
    max-height: clamp(360px, 540px, 80vh);
    overflow: scroll;
    scrollbar-width: none;
  }

  :host > wui-flex::-webkit-scrollbar {
    display: none;
  }
`;var $ee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let _y=class extends Ke.oi{constructor(){super(...arguments),this.disconecting=!1}render(){return Ke.dy`
      <wui-flex class="container" flexDirection="column" gap="0">
        <wui-flex
          class="container"
          flexDirection="column"
          .padding=${["m","xl","xs","xl"]}
          alignItems="center"
          gap="xl"
        >
          <wui-text variant="small-400" color="fg-200" align="center">
            This app doesn’t support your current network. Switch to an available option following
            to continue.
          </wui-text>
        </wui-flex>

        <wui-flex flexDirection="column" padding="s" gap="xs">
          ${this.networksTemplate()}
        </wui-flex>

        <wui-separator text="or"></wui-separator>
        <wui-flex flexDirection="column" padding="s" gap="xs">
          <wui-list-item
            variant="icon"
            iconVariant="overlay"
            icon="disconnect"
            ?chevron=${!1}
            .loading=${this.disconecting}
            @click=${this.onDisconnect.bind(this)}
            data-testid="disconnect-button"
          >
            <wui-text variant="paragraph-500" color="fg-200">Disconnect</wui-text>
          </wui-list-item>
        </wui-flex>
      </wui-flex>
    `}networksTemplate(){const{approvedCaipNetworkIds:n,requestedCaipNetworks:e}=ue.NetworkController.state;return ue.j1.sortRequestedNetworks(n,e).map(r=>Ke.dy`
        <wui-list-network
          imageSrc=${jn(ue.fz.getNetworkImage(r))}
          name=${r.name??"Unknown"}
          @click=${()=>this.onSwitchNetwork(r)}
        >
        </wui-list-network>
      `)}onDisconnect(){var n=this;return(0,Ge.Z)(function*(){try{n.disconecting=!0,yield ue.ConnectionController.disconnect(),ue.Xs.sendEvent({type:"track",event:"DISCONNECT_SUCCESS"}),ue.IN.close()}catch{ue.Xs.sendEvent({type:"track",event:"DISCONNECT_ERROR"}),ue.SnackController.showError("Failed to disconnect")}finally{n.disconecting=!1}})()}onSwitchNetwork(n){return(0,Ge.Z)(function*(){const{isConnected:e}=ue.AccountController.state,{approvedCaipNetworkIds:i,supportsAllNetworks:r,caipNetwork:s}=ue.NetworkController.state,{data:a}=ue.RouterController.state;e&&s?.id!==n.id?i?.includes(n.id)?(yield ue.NetworkController.switchActiveNetwork(n),ue._4.navigateAfterNetworkSwitch()):r&&ue.RouterController.push("SwitchNetwork",{...a,network:n}):e||(ue.NetworkController.setCaipNetwork(n),ue.RouterController.push("Connect"))})()}};_y.styles=QQe,$ee([(0,bt.SB)()],_y.prototype,"disconecting",void 0),_y=$ee([(0,Xt.customElement)("w3m-unsupported-chain-view")],_y);const JQe=Ke.iv`
  wui-compatible-network {
    margin-top: var(--wui-spacing-l);
  }
`;var by=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Rd=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.address=ue.AccountController.state.address,this.profileName=ue.AccountController.state.profileName,this.network=ue.NetworkController.state.caipNetwork,this.unsubscribe.push(ue.AccountController.subscribe(n=>{n.address?(this.address=n.address,this.profileName=n.profileName):ue.SnackController.showError("Account not found")}),ue.NetworkController.subscribeKey("caipNetwork",n=>{n?.id&&(this.network=n)}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){if(!this.address)throw new Error("w3m-wallet-receive-view: No account provided");const n=ue.fz.getNetworkImage(this.network);return Ke.dy` <wui-flex
      flexDirection="column"
      .padding=${["xl","l","l","l"]}
      alignItems="center"
    >
      <wui-chip-button
        @click=${this.onCopyClick.bind(this)}
        text=${Xt.UiHelperUtil.getTruncateString({string:this.address??"",charsStart:this.profileName?18:4,charsEnd:this.profileName?0:4,truncate:this.profileName?"end":"middle"})}
        icon="copy"
        imageSrc=${n||""}
        variant="shadeSmall"
      ></wui-chip-button>
      <wui-flex
        flexDirection="column"
        .padding=${["l","0","0","0"]}
        alignItems="center"
        gap="s"
      >
        <wui-qr-code
          size=${232}
          theme=${ue.ThemeController.state.themeMode}
          uri=${this.address}
          ?arenaClear=${!0}
          data-testid="wui-qr-code"
        ></wui-qr-code>
        <wui-text variant="paragraph-500" color="fg-100" align="center">
          Copy your address or scan this QR code
        </wui-text>
      </wui-flex>
      ${this.networkTemplate()}
    </wui-flex>`}networkTemplate(){const n=ue.NetworkController.getRequestedCaipNetworks(),e=ue.NetworkController.checkIfSmartAccountEnabled(),i=ue.NetworkController.state.caipNetwork;if(es.getPreferredAccountType()===wa.ACCOUNT_TYPES.SMART_ACCOUNT&&e)return i?Ke.dy`<wui-compatible-network
        @click=${this.onReceiveClick.bind(this)}
        text="Only receive assets on this network"
        .networkImages=${[ue.fz.getNetworkImage(i)??""]}
      ></wui-compatible-network>`:null;const a=(n?.filter(o=>o?.imageId)?.slice(0,5)).map(ue.fz.getNetworkImage).filter(Boolean);return Ke.dy`<wui-compatible-network
      @click=${this.onReceiveClick.bind(this)}
      text="Only receive assets on these networks"
      .networkImages=${a}
    ></wui-compatible-network>`}onReceiveClick(){ue.RouterController.push("WalletCompatibleNetworks")}onCopyClick(){try{this.address&&(ue.j1.copyToClopboard(this.address),ue.SnackController.showSuccess("Address copied"))}catch{ue.SnackController.showError("Failed to copy")}}};Rd.styles=JQe,by([(0,bt.SB)()],Rd.prototype,"address",void 0),by([(0,bt.SB)()],Rd.prototype,"profileName",void 0),by([(0,bt.SB)()],Rd.prototype,"network",void 0),Rd=by([(0,Xt.customElement)("w3m-wallet-receive-view")],Rd);const eJe=Ke.iv`
  :host > wui-flex {
    max-height: clamp(360px, 540px, 80vh);
    overflow: scroll;
    scrollbar-width: none;
  }

  :host > wui-flex::-webkit-scrollbar {
    display: none;
  }
`;let qA=class extends Ke.oi{render(){return Ke.dy` <wui-flex
      flexDirection="column"
      .padding=${["xs","s","m","s"]}
      gap="xs"
    >
      <wui-banner
        icon="warningCircle"
        text="You can only receive assets on these networks"
      ></wui-banner>
      ${this.networkTemplate()}
    </wui-flex>`}networkTemplate(){const{approvedCaipNetworkIds:n,requestedCaipNetworks:e,caipNetwork:i}=ue.NetworkController.state,r=ue.NetworkController.checkIfSmartAccountEnabled(),s=es.getPreferredAccountType();let a=ue.j1.sortRequestedNetworks(n,e);if(r&&s===wa.ACCOUNT_TYPES.SMART_ACCOUNT){if(!i)return null;a=[i]}return a.map(o=>Ke.dy`
        <wui-list-network
          imageSrc=${jn(ue.fz.getNetworkImage(o))}
          name=${o.name??"Unknown"}
          ?transparent=${!0}
        >
        </wui-list-network>
      `)}};qA.styles=eJe,qA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-wallet-compatible-networks-view")],qA);const nJe=Ke.iv`
  :host {
    display: block;
  }

  wui-flex {
    position: relative;
  }

  wui-icon-box {
    width: 40px;
    height: 40px;
    border-radius: var(--wui-border-radius-xs) !important;
    border: 5px solid var(--wui-color-bg-125);
    background: var(--wui-color-bg-175);
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 1;
  }

  wui-button {
    --local-border-radius: var(--wui-border-radius-xs) !important;
  }

  .inputContainer {
    height: fit-content;
  }
`;var Fh=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Q4=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.token=ue.Si.state.token,this.sendTokenAmount=ue.Si.state.sendTokenAmount,this.receiverAddress=ue.Si.state.receiverAddress,this.message="Preview Send",this.unsubscribe.push(ue.Si.subscribe(n=>{this.token=n.token,this.sendTokenAmount=n.sendTokenAmount,this.receiverAddress=n.receiverAddress}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return this.getMessage(),Ke.dy` <wui-flex flexDirection="column" .padding=${["s","l","l","l"]}>
      <wui-flex class="inputContainer" gap="xs" flexDirection="column">
        <w3m-input-token
          .token=${this.token}
          .sendTokenAmount=${this.sendTokenAmount}
        ></w3m-input-token>
        <wui-icon-box
          size="inherit"
          backgroundColor="fg-300"
          iconSize="lg"
          iconColor="fg-250"
          background="opaque"
          icon="arrowBottom"
        ></wui-icon-box>
        <w3m-input-address .receiverAddress=${this.receiverAddress}></w3m-input-address>
      </wui-flex>
      <wui-flex .margin=${["l","0","0","0"]}>
        <wui-button
          @click=${this.onButtonClick.bind(this)}
          ?disabled=${!this.message.startsWith("Preview Send")}
          size="lg"
          variant="fill"
          fullWidth
        >
          ${this.message}
        </wui-button>
      </wui-flex>
    </wui-flex>`}onButtonClick(){ue.RouterController.push("WalletSendPreview")}getMessage(){this.message="Preview Send",this.receiverAddress&&!ue.j1.isAddress(this.receiverAddress)&&(this.message="Invalid Address"),this.receiverAddress||(this.message="Add Address"),this.sendTokenAmount&&this.token&&this.sendTokenAmount>Number(this.token.quantity.numeric)&&(this.message="Insufficient Funds"),this.sendTokenAmount||(this.message="Add Amount"),this.token||(this.message="Select Token")}};Q4.styles=nJe,Fh([(0,bt.SB)()],Q4.prototype,"token",void 0),Fh([(0,bt.SB)()],Q4.prototype,"sendTokenAmount",void 0),Fh([(0,bt.SB)()],Q4.prototype,"receiverAddress",void 0),Fh([(0,bt.SB)()],Q4.prototype,"message",void 0),Q4=Fh([(0,Xt.customElement)("w3m-wallet-send-view")],Q4);const iJe=Ke.iv`
  .contentContainer {
    height: 440px;
    overflow: scroll;
    scrollbar-width: none;
  }

  wui-icon-box {
    width: 40px;
    height: 40px;
    border-radius: var(--wui-border-radius-xxs);
  }
`;var wy=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Ld=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.tokenBalance=ue.AccountController.state.tokenBalance,this.search="",this.onDebouncedSearch=ue.j1.debounce(n=>{this.search=n}),this.unsubscribe.push(ue.AccountController.subscribe(n=>{this.tokenBalance=n.tokenBalance}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-flex flexDirection="column">
        ${this.templateSearchInput()} <wui-separator></wui-separator> ${this.templateTokens()}
      </wui-flex>
    `}templateSearchInput(){return Ke.dy`
      <wui-flex gap="xs" padding="s">
        <wui-input-text
          @inputChange=${this.onInputChange.bind(this)}
          class="network-search-input"
          size="sm"
          placeholder="Search token"
          icon="search"
        ></wui-input-text>
      </wui-flex>
    `}templateTokens(){return this.tokens=this.search?this.tokenBalance?.filter(n=>n.name.toLowerCase().includes(this.search.toLowerCase())):this.tokenBalance,Ke.dy`
      <wui-flex
        class="contentContainer"
        flexDirection="column"
        .padding=${["0","s","0","s"]}
      >
        <wui-flex justifyContent="flex-start" .padding=${["m","s","s","s"]}>
          <wui-text variant="paragraph-500" color="fg-200">Your tokens</wui-text>
        </wui-flex>
        <wui-flex flexDirection="column" gap="xs">
          ${this.tokens&&this.tokens.length>0?this.tokens.map(n=>Ke.dy`<wui-list-token
                    @click=${this.handleTokenClick.bind(this,n)}
                    ?clickable=${!0}
                    tokenName=${n.name}
                    tokenImageUrl=${n.iconUrl}
                    tokenAmount=${n.quantity.numeric}
                    tokenValue=${n.value}
                    tokenCurrency=${n.symbol}
                  ></wui-list-token>`):Ke.dy`<wui-flex
                .padding=${["4xl","0","0","0"]}
                alignItems="center"
                flexDirection="column"
                gap="l"
              >
                <wui-icon-box
                  icon="coinPlaceholder"
                  size="inherit"
                  iconColor="fg-200"
                  backgroundColor="fg-200"
                  iconSize="lg"
                ></wui-icon-box>
                <wui-flex
                  class="textContent"
                  gap="xs"
                  flexDirection="column"
                  justifyContent="center"
                  flexDirection="column"
                >
                  <wui-text variant="paragraph-500" align="center" color="fg-100"
                    >No tokens found</wui-text
                  >
                  <wui-text variant="small-400" align="center" color="fg-200"
                    >Your tokens will appear here</wui-text
                  >
                </wui-flex>
                <wui-link @click=${this.onBuyClick.bind(this)}>Buy</wui-link>
              </wui-flex>`}
        </wui-flex>
      </wui-flex>
    `}onBuyClick(){ue.RouterController.push("OnRampProviders")}onInputChange(n){this.onDebouncedSearch(n.detail)}handleTokenClick(n){ue.Si.setToken(n),ue.Si.setTokenAmount(void 0),ue.RouterController.goBack()}};Ld.styles=iJe,wy([(0,bt.SB)()],Ld.prototype,"tokenBalance",void 0),wy([(0,bt.SB)()],Ld.prototype,"tokens",void 0),wy([(0,bt.SB)()],Ld.prototype,"search",void 0),Ld=wy([(0,Xt.customElement)("w3m-wallet-send-select-token-view")],Ld);const rJe=Ke.iv`
  wui-avatar,
  wui-image {
    display: ruby;
    width: 32px;
    height: 32px;
    border-radius: var(--wui-border-radius-3xl);
  }

  .sendButton {
    width: 70%;
    --local-width: 100% !important;
    --local-border-radius: var(--wui-border-radius-xs) !important;
  }

  .cancelButton {
    width: 30%;
    --local-width: 100% !important;
    --local-border-radius: var(--wui-border-radius-xs) !important;
  }
`;var Bh=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let J4=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.token=ue.Si.state.token,this.sendTokenAmount=ue.Si.state.sendTokenAmount,this.receiverAddress=ue.Si.state.receiverAddress,this.caipNetwork=ue.NetworkController.state.caipNetwork,this.unsubscribe.push(ue.Si.subscribe(n=>{this.token=n.token,this.sendTokenAmount=n.sendTokenAmount,this.receiverAddress=n.receiverAddress}),ue.NetworkController.subscribeKey("caipNetwork",n=>this.caipNetwork=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy` <wui-flex flexDirection="column" .padding=${["s","l","l","l"]}>
      <wui-flex gap="xs" flexDirection="column" .padding=${["0","xs","0","xs"]}>
        <wui-flex alignItems="center" justifyContent="space-between">
          <wui-flex flexDirection="column" gap="4xs">
            <wui-text variant="small-400" color="fg-150">Send</wui-text>
            ${this.sendValueTemplate()}
          </wui-flex>
          <wui-preview-item
            text="${Number(this.token?.quantity.numeric).toFixed(2)} ${this.token?.symbol}"
            .imageSrc=${this.token?.iconUrl}
          ></wui-preview-item>
        </wui-flex>
        <wui-flex>
          <wui-icon color="fg-200" size="md" name="arrowBottom"></wui-icon>
        </wui-flex>
        <wui-flex alignItems="center" justifyContent="space-between">
          <wui-text variant="small-400" color="fg-150">To</wui-text>
          <wui-preview-item
            text=${Xt.UiHelperUtil.getTruncateString({string:this.receiverAddress??"",charsStart:4,charsEnd:4,truncate:"middle"})}
            address=${this.receiverAddress??""}
            .isAddress=${!0}
          ></wui-preview-item>
        </wui-flex>
      </wui-flex>
      <wui-flex flexDirection="column" .padding=${["xxl","0","0","0"]}>
        <w3m-wallet-send-details
          .caipNetwork=${this.caipNetwork}
          .receiverAddress=${this.receiverAddress}
        ></w3m-wallet-send-details>
        <wui-flex justifyContent="center" gap="xxs" .padding=${["s","0","0","0"]}>
          <wui-icon size="sm" color="fg-200" name="warningCircle"></wui-icon>
          <wui-text variant="small-400" color="fg-200">Review transaction carefully</wui-text>
        </wui-flex>
        <wui-flex justifyContent="center" gap="s" .padding=${["l","0","0","0"]}>
          <wui-button
            class="cancelButton"
            @click=${this.onCancelClick.bind(this)}
            size="lg"
            variant="shade"
          >
            Cancel
          </wui-button>
          <wui-button
            class="sendButton"
            @click=${this.onSendClick.bind(this)}
            size="lg"
            variant="fill"
          >
            Send
          </wui-button>
        </wui-flex>
      </wui-flex></wui-flex
    >`}sendValueTemplate(){return this.token&&this.sendTokenAmount?Ke.dy`<wui-text variant="paragraph-400" color="fg-100"
        >$${(this.token.price*this.sendTokenAmount).toFixed(2)}</wui-text
      >`:null}onSendClick(){ue.RouterController.reset("Account"),setTimeout(()=>{ue.Si.resetSend()},200)}onCancelClick(){ue.RouterController.goBack()}};J4.styles=rJe,Bh([(0,bt.SB)()],J4.prototype,"token",void 0),Bh([(0,bt.SB)()],J4.prototype,"sendTokenAmount",void 0),Bh([(0,bt.SB)()],J4.prototype,"receiverAddress",void 0),Bh([(0,bt.SB)()],J4.prototype,"caipNetwork",void 0),J4=Bh([(0,Xt.customElement)("w3m-wallet-send-preview-view")],J4);const sJe=Ke.iv`
  wui-grid {
    max-height: clamp(360px, 400px, 80vh);
    overflow: scroll;
    scrollbar-width: none;
    grid-auto-rows: min-content;
    grid-template-columns: repeat(auto-fill, 76px);
  }

  @media (max-width: 435px) {
    wui-grid {
      grid-template-columns: repeat(auto-fill, 77px);
    }
  }

  wui-grid[data-scroll='false'] {
    overflow: hidden;
  }

  wui-grid::-webkit-scrollbar {
    display: none;
  }

  wui-loading-spinner {
    padding-top: var(--wui-spacing-l);
    padding-bottom: var(--wui-spacing-l);
    justify-content: center;
    grid-column: 1 / span 4;
  }
`;function jee(t){const{connectors:n}=ue.ConnectorController.state,e=n.filter(s=>"ANNOUNCED"===s.type).reduce((s,a)=>(a.info?.rdns&&(s[a.info.rdns]=!0),s),{});return t.map(s=>({...s,installed:!!s.rdns&&!!e[s.rdns??""]})).sort((s,a)=>Number(a.installed)-Number(s.installed))}var Uh=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};const Wee="local-paginator";let eu=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.paginationObserver=void 0,this.initial=!ue.ApiController.state.wallets.length,this.wallets=ue.ApiController.state.wallets,this.recommended=ue.ApiController.state.recommended,this.featured=ue.ApiController.state.featured,this.unsubscribe.push(ue.ApiController.subscribeKey("wallets",n=>this.wallets=n),ue.ApiController.subscribeKey("recommended",n=>this.recommended=n),ue.ApiController.subscribeKey("featured",n=>this.featured=n))}firstUpdated(){this.initialFetch(),this.createPaginationObserver()}disconnectedCallback(){this.unsubscribe.forEach(n=>n()),this.paginationObserver?.disconnect()}render(){return Ke.dy`
      <wui-grid
        data-scroll=${!this.initial}
        .padding=${["0","s","s","s"]}
        columnGap="xxs"
        rowGap="l"
        justifyContent="space-between"
      >
        ${this.initial?this.shimmerTemplate(16):this.walletsTemplate()}
        ${this.paginationLoaderTemplate()}
      </wui-grid>
    `}initialFetch(){var n=this;return(0,Ge.Z)(function*(){const e=n.shadowRoot?.querySelector("wui-grid");n.initial&&e&&(yield ue.ApiController.fetchWallets({page:1}),yield e.animate([{opacity:1},{opacity:0}],{duration:200,fill:"forwards",easing:"ease"}).finished,n.initial=!1,e.animate([{opacity:0},{opacity:1}],{duration:200,fill:"forwards",easing:"ease"}))})()}shimmerTemplate(n,e){return[...Array(n)].map(()=>Ke.dy`
        <wui-card-select-loader type="wallet" id=${jn(e)}></wui-card-select-loader>
      `)}walletsTemplate(){return jee([...this.featured,...this.recommended,...this.wallets]).map(i=>Ke.dy`
        <wui-card-select
          imageSrc=${jn(ue.fz.getWalletImage(i))}
          type="wallet"
          name=${i.name}
          @click=${()=>this.onConnectWallet(i)}
          .installed=${i.installed}
        ></wui-card-select>
      `)}paginationLoaderTemplate(){const{wallets:n,recommended:e,featured:i,count:r}=ue.ApiController.state,s=window.innerWidth<352?3:4,a=n.length+e.length;let c=Math.ceil(a/s)*s-a+s;return c-=n.length?i.length%s:0,0===r&&i.length>0?null:0===r||[...i,...n,...e].length<r?this.shimmerTemplate(c,Wee):null}createPaginationObserver(){const n=this.shadowRoot?.querySelector(`#${Wee}`);n&&(this.paginationObserver=new IntersectionObserver(([e])=>{if(e?.isIntersecting&&!this.initial){const{page:i,count:r,wallets:s}=ue.ApiController.state;s.length<r&&ue.ApiController.fetchWallets({page:i+1})}}),this.paginationObserver.observe(n))}onConnectWallet(n){const e=ue.ConnectorController.getConnector(n.id,n.rdns);e?ue.RouterController.push("ConnectingExternal",{connector:e}):ue.RouterController.push("ConnectingWalletConnect",{wallet:n})}};eu.styles=sJe,Uh([(0,bt.SB)()],eu.prototype,"initial",void 0),Uh([(0,bt.SB)()],eu.prototype,"wallets",void 0),Uh([(0,bt.SB)()],eu.prototype,"recommended",void 0),Uh([(0,bt.SB)()],eu.prototype,"featured",void 0),eu=Uh([(0,Xt.customElement)("w3m-all-wallets-list")],eu);const aJe=Ke.iv`
  wui-grid,
  wui-loading-spinner,
  wui-flex {
    height: 360px;
  }

  wui-grid {
    overflow: scroll;
    scrollbar-width: none;
    grid-auto-rows: min-content;
  }

  wui-grid[data-scroll='false'] {
    overflow: hidden;
  }

  wui-grid::-webkit-scrollbar {
    display: none;
  }

  wui-loading-spinner {
    justify-content: center;
    align-items: center;
  }
`;var GA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let $h=class extends Ke.oi{constructor(){super(...arguments),this.prevQuery="",this.loading=!0,this.query=""}render(){return this.onSearch(),this.loading?Ke.dy`<wui-loading-spinner color="accent-100"></wui-loading-spinner>`:this.walletsTemplate()}onSearch(){var n=this;return(0,Ge.Z)(function*(){n.query!==n.prevQuery&&(n.prevQuery=n.query,n.loading=!0,yield ue.ApiController.searchWallet({search:n.query}),n.loading=!1)})()}walletsTemplate(){const{search:n}=ue.ApiController.state,e=jee(n);return n.length?Ke.dy`
      <wui-grid
        .padding=${["0","s","s","s"]}
        gridTemplateColumns="repeat(4, 1fr)"
        rowGap="l"
        columnGap="xs"
      >
        ${e.map(i=>Ke.dy`
            <wui-card-select
              imageSrc=${jn(ue.fz.getWalletImage(i))}
              type="wallet"
              name=${i.name}
              @click=${()=>this.onConnectWallet(i)}
              .installed=${i.installed}
            ></wui-card-select>
          `)}
      </wui-grid>
    `:Ke.dy`
        <wui-flex justifyContent="center" alignItems="center" gap="s" flexDirection="column">
          <wui-icon-box
            size="lg"
            iconColor="fg-200"
            backgroundColor="fg-300"
            icon="wallet"
            background="transparent"
          ></wui-icon-box>
          <wui-text color="fg-200" variant="paragraph-500">No Wallet found</wui-text>
        </wui-flex>
      `}onConnectWallet(n){const e=ue.ConnectorController.getConnector(n.id,n.rdns);e?ue.RouterController.push("ConnectingExternal",{connector:e}):ue.RouterController.push("ConnectingWalletConnect",{wallet:n})}};$h.styles=aJe,GA([(0,bt.SB)()],$h.prototype,"loading",void 0),GA([(0,bt.Cb)()],$h.prototype,"query",void 0),$h=GA([(0,Xt.customElement)("w3m-all-wallets-search")],$h);var Cy=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let jh=class extends Ke.oi{constructor(){super(),this.platformTabs=[],this.unsubscribe=[],this.platforms=[],this.onSelectPlatfrom=void 0,this.buffering=!1,this.unsubscribe.push(ue.ConnectionController.subscribeKey("buffering",n=>this.buffering=n))}disconnectCallback(){this.unsubscribe.forEach(n=>n())}render(){const n=this.generateTabs();return Ke.dy`
      <wui-flex justifyContent="center" .padding=${["l","0","0","0"]}>
        <wui-tabs
          ?disabled=${this.buffering}
          .tabs=${n}
          .onTabChange=${this.onTabChange.bind(this)}
        ></wui-tabs>
      </wui-flex>
    `}generateTabs(){const n=this.platforms.map(e=>"browser"===e?{label:"Browser",icon:"extension",platform:"browser"}:"mobile"===e?{label:"Mobile",icon:"mobile",platform:"mobile"}:"qrcode"===e?{label:"Mobile",icon:"mobile",platform:"qrcode"}:"web"===e?{label:"Webapp",icon:"browser",platform:"web"}:"desktop"===e?{label:"Desktop",icon:"desktop",platform:"desktop"}:{label:"Browser",icon:"extension",platform:"unsupported"});return this.platformTabs=n.map(({platform:e})=>e),n}onTabChange(n){const e=this.platformTabs[n];e&&this.onSelectPlatfrom?.(e)}};Cy([(0,bt.Cb)({type:Array})],jh.prototype,"platforms",void 0),Cy([(0,bt.Cb)()],jh.prototype,"onSelectPlatfrom",void 0),Cy([(0,bt.SB)()],jh.prototype,"buffering",void 0),jh=Cy([(0,Xt.customElement)("w3m-connecting-header")],jh);let qee=class extends Uo{constructor(){if(super(),!this.wallet)throw new Error("w3m-connecting-wc-browser: No wallet provided");this.onConnect=this.onConnectProxy.bind(this),this.onAutoConnect=this.onConnectProxy.bind(this),ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.wallet.name,platform:"browser"}})}onConnectProxy(){var n=this;return(0,Ge.Z)(function*(){try{n.error=!1;const{connectors:e}=ue.ConnectorController.state,i=e.find(s=>"ANNOUNCED"===s.type&&s.info?.rdns===n.wallet?.rdns),r=e.find(s=>"INJECTED"===s.type);i?yield ue.ConnectionController.connectExternal(i):r&&(yield ue.ConnectionController.connectExternal(r)),ue.IN.close(),ue.Xs.sendEvent({type:"track",event:"CONNECT_SUCCESS",properties:{method:"browser",name:n.wallet?.name||"Unknown"}})}catch(e){ue.Xs.sendEvent({type:"track",event:"CONNECT_ERROR",properties:{message:e?.message??"Unknown"}}),n.error=!0}})()}};qee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-wc-browser")],qee);let Gee=class extends Uo{constructor(){if(super(),!this.wallet)throw new Error("w3m-connecting-wc-desktop: No wallet provided");this.onConnect=this.onConnectProxy.bind(this),this.onRender=this.onRenderProxy.bind(this),ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.wallet.name,platform:"desktop"}})}onRenderProxy(){!this.ready&&this.uri&&(this.ready=!0,this.timeout=setTimeout(()=>{this.onConnect?.()},200))}onConnectProxy(){if(this.wallet?.desktop_link&&this.uri)try{this.error=!1;const{desktop_link:n,name:e}=this.wallet,{redirect:i,href:r}=ue.j1.formatNativeUrl(n,this.uri);ue.ConnectionController.setWcLinking({name:e,href:r}),ue.ConnectionController.setRecentWallet(this.wallet),ue.j1.openHref(i,"_blank")}catch{this.error=!0}}};Gee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-wc-desktop")],Gee);let Zee=class extends Uo{constructor(){if(super(),!this.wallet)throw new Error("w3m-connecting-wc-mobile: No wallet provided");this.onConnect=this.onConnectProxy.bind(this),this.onRender=this.onRenderProxy.bind(this),document.addEventListener("visibilitychange",this.onBuffering.bind(this)),ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.wallet.name,platform:"mobile"}})}disconnectedCallback(){super.disconnectedCallback(),document.removeEventListener("visibilitychange",this.onBuffering.bind(this))}onRenderProxy(){!this.ready&&this.uri&&(this.ready=!0,this.onConnect?.())}onConnectProxy(){if(this.wallet?.mobile_link&&this.uri)try{this.error=!1;const{mobile_link:n,name:e}=this.wallet,{redirect:i,href:r}=ue.j1.formatNativeUrl(n,this.uri);ue.ConnectionController.setWcLinking({name:e,href:r}),ue.ConnectionController.setRecentWallet(this.wallet),ue.j1.openHref(i,"_self")}catch{this.error=!0}}onBuffering(){const n=ue.j1.isIos();"visible"===document?.visibilityState&&!this.error&&n&&(ue.ConnectionController.setBuffering(!0),setTimeout(()=>{ue.ConnectionController.setBuffering(!1)},5e3))}};Zee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-wc-mobile")],Zee);const uJe=Ke.iv`
  @keyframes fadein {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  wui-shimmer {
    width: 100%;
    aspect-ratio: 1 / 1;
    border-radius: clamp(0px, var(--wui-border-radius-l), 40px) !important;
  }

  wui-qr-code {
    opacity: 0;
    animation-duration: 200ms;
    animation-timing-function: ease;
    animation-name: fadein;
    animation-fill-mode: forwards;
  }
`;let ZA=class extends Uo{constructor(){super(),this.forceUpdate=()=>{this.requestUpdate()},window.addEventListener("resize",this.forceUpdate),ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.wallet?.name??"WalletConnect",platform:"qrcode"}})}disconnectedCallback(){super.disconnectedCallback(),window.removeEventListener("resize",this.forceUpdate)}render(){return this.onRenderProxy(),Ke.dy`
      <wui-flex padding="xl" flexDirection="column" gap="xl" alignItems="center">
        <wui-shimmer borderRadius="l" width="100%"> ${this.qrCodeTemplate()} </wui-shimmer>

        <wui-text variant="paragraph-500" color="fg-100">
          Scan this QR Code with your phone
        </wui-text>
        ${this.copyTemplate()}
      </wui-flex>

      <w3m-mobile-download-links .wallet=${this.wallet}></w3m-mobile-download-links>
    `}onRenderProxy(){!this.ready&&this.uri&&(this.timeout=setTimeout(()=>{this.ready=!0},200))}qrCodeTemplate(){if(!this.uri||!this.ready)return null;const n=this.getBoundingClientRect().width-40,e=this.wallet?this.wallet.name:void 0;return ue.ConnectionController.setWcLinking(void 0),ue.ConnectionController.setRecentWallet(this.wallet),Ke.dy` <wui-qr-code
      size=${n}
      theme=${ue.ThemeController.state.themeMode}
      uri=${this.uri}
      imageSrc=${jn(ue.fz.getWalletImage(this.wallet))}
      alt=${jn(e)}
      data-testid="wui-qr-code"
    ></wui-qr-code>`}copyTemplate(){return Ke.dy`<wui-link
      .disabled=${!this.uri||!this.ready}
      @click=${this.onCopyUri}
      color="fg-200"
      data-testid="copy-wc2-uri"
    >
      <wui-icon size="xs" color="fg-200" slot="iconLeft" name="copy"></wui-icon>
      Copy link
    </wui-link>`}};ZA.styles=uJe,ZA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-wc-qrcode")],ZA);let Yee=class extends Ke.oi{constructor(){if(super(),this.wallet=ue.RouterController.state.data?.wallet,!this.wallet)throw new Error("w3m-connecting-wc-unsupported: No wallet provided");ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.wallet.name,platform:"browser"}})}render(){return Ke.dy`
      <wui-flex
        flexDirection="column"
        alignItems="center"
        .padding=${["3xl","xl","xl","xl"]}
        gap="xl"
      >
        <wui-wallet-image
          size="lg"
          imageSrc=${jn(ue.fz.getWalletImage(this.wallet))}
        ></wui-wallet-image>

        <wui-text variant="paragraph-500" color="fg-100">Not Detected</wui-text>
      </wui-flex>

      <w3m-mobile-download-links .wallet=${this.wallet}></w3m-mobile-download-links>
    `}};Yee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-wc-unsupported")],Yee);let Kee=class extends Uo{constructor(){if(super(),!this.wallet)throw new Error("w3m-connecting-wc-web: No wallet provided");this.onConnect=this.onConnectProxy.bind(this),this.secondaryBtnLabel="Open",this.secondaryLabel="Open and continue in a new browser tab",this.secondaryBtnIcon="externalLink",ue.Xs.sendEvent({type:"track",event:"SELECT_WALLET",properties:{name:this.wallet.name,platform:"web"}})}onConnectProxy(){if(this.wallet?.webapp_link&&this.uri)try{this.error=!1;const{webapp_link:n,name:e}=this.wallet,{redirect:i,href:r}=ue.j1.formatUniversalUrl(n,this.uri);ue.ConnectionController.setWcLinking({name:e,href:r}),ue.ConnectionController.setRecentWallet(this.wallet),ue.j1.openHref(i,"_blank")}catch{this.error=!0}}};Kee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-connecting-wc-web")],Kee);const pJe=Ke.iv`
  :host {
    width: 100%;
  }

  .details-container > wui-flex {
    background: var(--wui-gray-glass-002);
    border-radius: var(--wui-border-radius-xxs);
    width: 100%;
  }

  .details-container > wui-flex > button {
    border: none;
    background: none;
    padding: var(--wui-spacing-s);
    border-radius: var(--wui-border-radius-xxs);
    cursor: pointer;
  }

  .details-content-container {
    padding: var(--wui-spacing-1xs);
    padding-top: 0px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .details-content-container > wui-flex {
    width: 100%;
  }

  .details-row {
    width: 100%;
    padding: var(--wui-spacing-s);
    padding-left: var(--wui-spacing-s);
    padding-right: var(--wui-spacing-1xs);
    border-radius: calc(var(--wui-border-radius-5xs) + var(--wui-border-radius-4xs));
    background: var(--wui-gray-glass-002);
  }

  .details-row.provider-free-row {
    padding-right: var(--wui-spacing-xs);
  }

  .free-badge {
    background: rgba(38, 217, 98, 0.15);
    border-radius: var(--wui-border-radius-4xs);
    padding: 4.5px 6px;
  }
`;var Nc=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let l2=class extends Ke.oi{constructor(){super(...arguments),this.detailsOpen=!1,this.slippageRate=.5}render(){return Ke.dy`
      <wui-flex flexDirection="column" alignItems="center" gap="1xs" class="details-container">
        <wui-flex flexDirection="column">
          <button @click=${this.toggleDetails.bind(this)}>
            <wui-flex justifyContent="space-between" .padding=${["0","xs","0","xs"]}>
              <wui-flex justifyContent="flex-start" flexGrow="1" gap="xs">
                <wui-text variant="small-400" color="fg-100"
                  >1 ${this.sourceTokenSymbol} =
                  ${Xt.UiHelperUtil.formatNumberToLocalString(this.toTokenConvertedAmount,3)}
                  ${this.toTokenSymbol}</wui-text
                >
                <wui-text variant="small-400" color="fg-200">
                  $${Xt.UiHelperUtil.formatNumberToLocalString(this.sourceTokenPrice)}
                </wui-text>
              </wui-flex>
              <wui-icon name="chevronBottom"></wui-icon>
            </wui-flex>
          </button>
          ${this.detailsOpen?Ke.dy`
                <wui-flex flexDirection="column" gap="xs" class="details-content-container">
                  <wui-flex flexDirection="column" gap="xs">
                    <wui-flex
                      justifyContent="space-between"
                      alignItems="center"
                      class="details-row"
                    >
                      <wui-text variant="small-400" color="fg-150">Network cost</wui-text>
                      <wui-text variant="small-400" color="fg-100">
                        $${Xt.UiHelperUtil.formatNumberToLocalString(this.gasPriceInUSD,3)}
                      </wui-text>
                    </wui-flex>
                  </wui-flex>
                  ${this.priceImpact?Ke.dy` <wui-flex flexDirection="column" gap="xs">
                        <wui-flex
                          justifyContent="space-between"
                          alignItems="center"
                          class="details-row"
                        >
                          <wui-text variant="small-400" color="fg-150">Price impact</wui-text>
                          <wui-flex>
                            <wui-text variant="small-400" color="fg-200">
                              ${Xt.UiHelperUtil.formatNumberToLocalString(this.priceImpact,3)}%
                            </wui-text>
                          </wui-flex>
                        </wui-flex>
                      </wui-flex>`:null}
                  ${this.maxSlippage&&this.sourceTokenSymbol?Ke.dy`<wui-flex flexDirection="column" gap="xs">
                        <wui-flex
                          justifyContent="space-between"
                          alignItems="center"
                          class="details-row"
                        >
                          <wui-text variant="small-400" color="fg-150">Max. slippage</wui-text>
                          <wui-flex>
                            <wui-text variant="small-400" color="fg-200">
                              ${Xt.UiHelperUtil.formatNumberToLocalString(this.maxSlippage,6)}
                              ${this.sourceTokenSymbol} ${this.slippageRate}%
                            </wui-text>
                          </wui-flex>
                        </wui-flex>
                      </wui-flex>`:null}
                  <wui-flex flexDirection="column" gap="xs">
                    <wui-flex
                      justifyContent="space-between"
                      alignItems="center"
                      class="details-row provider-free-row"
                    >
                      <wui-text variant="small-400" color="fg-150">Provider fee</wui-text>
                      <wui-flex alignItems="center" justifyContent="center" class="free-badge">
                        <wui-text variant="micro-700" color="success-100">Free</wui-text>
                      </wui-flex>
                    </wui-flex>
                  </wui-flex>
                </wui-flex>
              `:null}
        </wui-flex>
      </wui-flex>
    `}toggleDetails(){this.detailsOpen=!this.detailsOpen}};l2.styles=[pJe],Nc([(0,bt.Cb)()],l2.prototype,"detailsOpen",void 0),Nc([(0,bt.Cb)()],l2.prototype,"sourceTokenSymbol",void 0),Nc([(0,bt.Cb)()],l2.prototype,"sourceTokenPrice",void 0),Nc([(0,bt.Cb)()],l2.prototype,"toTokenSymbol",void 0),Nc([(0,bt.Cb)()],l2.prototype,"toTokenConvertedAmount",void 0),Nc([(0,bt.Cb)()],l2.prototype,"gasPriceInUSD",void 0),Nc([(0,bt.Cb)()],l2.prototype,"priceImpact",void 0),Nc([(0,bt.Cb)()],l2.prototype,"slippageRate",void 0),Nc([(0,bt.Cb)()],l2.prototype,"maxSlippage",void 0),l2=Nc([(0,Xt.customElement)("w3m-convert-details")],l2);const mJe=Ke.iv`
  :host > wui-flex {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    border-radius: var(--wui-border-radius-s);
    padding: var(--wui-spacing-xl);
    padding-right: var(--wui-spacing-s);
    width: 100%;
    height: 100px;
    box-sizing: border-box;
    position: relative;
  }

  :host > wui-flex > svg.input_mask {
    position: absolute;
    inset: 0;
    z-index: 5;
  }

  :host wui-flex .input_mask__border,
  :host wui-flex .input_mask__background {
    transition: fill var(--wui-duration-md) var(--wui-ease-out-power-1);
    will-change: fill;
  }

  :host wui-flex .input_mask__border {
    fill: var(--wui-gray-glass-005);
  }

  :host wui-flex .input_mask__background {
    fill: var(--wui-gray-glass-002);
  }

  :host wui-flex.focus .input_mask__border {
    fill: var(--wui-gray-glass-020);
  }

  :host > wui-flex .swap-input,
  :host > wui-flex .swap-token-button {
    z-index: 10;
  }

  :host > wui-flex .swap-input {
    -webkit-mask-image: linear-gradient(
      270deg,
      transparent 0px,
      transparent 8px,
      black 24px,
      black 25px,
      black 32px,
      black 100%
    );
    mask-image: linear-gradient(
      270deg,
      transparent 0px,
      transparent 8px,
      black 24px,
      black 25px,
      black 32px,
      black 100%
    );
  }

  :host > wui-flex .swap-input input {
    background: none;
    border: none;
    height: 42px;
    width: 100%;
    font-size: 32px;
    font-style: normal;
    font-weight: 400;
    line-height: 130%;
    letter-spacing: -1.28px;
    outline: none;
    caret-color: var(--wui-color-accent-100);
    color: var(--wui-color-fg-200);
  }

  :host > wui-flex .swap-input input:focus-visible {
    outline: none;
  }

  :host > wui-flex .swap-input input::-webkit-outer-spin-button,
  :host > wui-flex .swap-input input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  .token-select-button {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--wui-spacing-xxs);
    padding: var(--wui-spacing-xs);
    padding-right: var(--wui-spacing-1xs);
    height: 40px;
    border: none;
    border-radius: 80px;
    background: var(--wui-gray-glass-002);
    box-shadow: inset 0 0 0 1px var(--wui-gray-glass-002);
    cursor: pointer;
    transition: background 0.2s linear;
  }

  .token-select-button:hover {
    background: var(--wui-gray-glass-005);
  }

  .token-select-button wui-image {
    width: 24px;
    height: 24px;
    border-radius: var(--wui-border-radius-s);
    box-shadow: inset 0 0 0 1px var(--wui-gray-glass-010);
  }

  .max-value-button {
    background-color: transparent;
    border: none;
    cursor: pointer;
    color: var(--wui-gray-glass-020);
  }

  .market-value {
    min-height: 18px;
  }
`;var q2=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let I1=class extends Ke.oi{constructor(){super(...arguments),this.focused=!1,this.price=0,this.marketValue="$1.0345,00",this.target="sourceToken",this.onSetAmount=null,this.onSetMaxValue=null}render(){const e=Dc.C6.bigNumber(this.marketValue||"0").isGreaterThan(0);return Ke.dy`
      <wui-flex class="${this.focused?"focus":""}" justifyContent="space-between">
        ${"sourceToken"===this.target?Xt.convertInputMaskTopSvg:Xt.convertInputMaskBottomSvg}
        <wui-flex
          flex="1"
          flexDirection="column"
          alignItems="flex-start"
          justifyContent="center"
          class="swap-input"
        >
          <input
            @focusin=${()=>this.onFocusChange(!0)}
            @focusout=${()=>this.onFocusChange(!1)}
            ?disabled=${this.disabled}
            .value=${this.value}
            @input=${this.dispatchInputChangeEvent}
            @keydown=${this.handleKeydown}
            placeholder="0"
          />
          <wui-text class="market-value" variant="small-400" color="fg-200">
            ${e?`$${this.marketValue}`:null}
          </wui-text>
        </wui-flex>
        ${this.templateTokenSelectButton()}
      </wui-flex>
    `}handleKeydown(n){const i=","===n.key,r="."===n.key,a=this.value;!(n.key>="0"&&n.key<="9")&&!["Backspace","Meta","Ctrl","a","c","v","ArrowLeft","ArrowRight","Tab"].includes(n.key)&&!r&&!i&&n.preventDefault(),(i||r)&&(a?.includes(".")||a?.includes(","))&&n.preventDefault()}dispatchInputChangeEvent(n){if(!this.onSetAmount)return;const e=n.target.value;","===e||"."===e?this.onSetAmount(this.target,"0."):e.endsWith(",")?this.onSetAmount(this.target,e.replace(",",".")):this.onSetAmount(this.target,e)}setMaxValueToInput(){this.onSetMaxValue?.(this.target,this.balance)}templateTokenSelectButton(){if(!this.token)return Ke.dy` <wui-button
        class="swap-token-button"
        size="md"
        variant="accentBg"
        @click=${this.onSelectToken.bind(this)}
      >
        Select token
      </wui-button>`;const n=this.token.logoURI?Ke.dy`<wui-image src=${this.token.logoURI}></wui-image>`:Ke.dy`
          <wui-icon-box
            size="sm"
            iconColor="fg-200"
            backgroundColor="fg-300"
            icon="networkPlaceholder"
          ></wui-icon-box>
        `;return Ke.dy`
      <wui-flex
        class="swap-token-button"
        flexDirection="column"
        alignItems="flex-end"
        justifyContent="center"
        gap="xxs"
      >
        <button
          size="sm"
          variant="shade"
          class="token-select-button"
          @click=${this.onSelectToken.bind(this)}
        >
          ${n}
          <wui-text variant="paragraph-600" color="fg-100">${this.token.symbol}</wui-text>
        </button>
        <wui-flex alignItems="center" gap="xxs"> ${this.tokenBalanceTemplate()} </wui-flex>
      </wui-flex>
    `}tokenBalanceTemplate(){const n=Dc.C6.multiply(this.balance,this.price),e=!!n&&n?.isGreaterThan(5e-5);return Ke.dy`
      ${e?Ke.dy`<wui-text variant="small-400" color="fg-200">
            ${Xt.UiHelperUtil.formatNumberToLocalString(this.balance,3)}
          </wui-text>`:null}
      ${"sourceToken"===this.target?this.tokenActionButtonTemplate(e):null}
    `}tokenActionButtonTemplate(n){return n?Ke.dy` <button class="max-value-button" @click=${this.setMaxValueToInput.bind(this)}>
        <wui-text color="accent-100" variant="small-600">Max</wui-text>
      </button>`:Ke.dy` <button class="max-value-button" @click=${this.onBuyToken.bind(this)}>
      <wui-text color="accent-100" variant="small-600">Buy</wui-text>
    </button>`}onFocusChange(n){this.focused=n}onSelectToken(){ue.Xs.sendEvent({type:"track",event:"CLICK_SELECT_TOKEN_TO_SWAP"})}onBuyToken(){ue.RouterController.push("OnRampProviders")}};I1.styles=[mJe],q2([(0,bt.Cb)()],I1.prototype,"focused",void 0),q2([(0,bt.Cb)()],I1.prototype,"balance",void 0),q2([(0,bt.Cb)()],I1.prototype,"value",void 0),q2([(0,bt.Cb)()],I1.prototype,"price",void 0),q2([(0,bt.Cb)()],I1.prototype,"marketValue",void 0),q2([(0,bt.Cb)()],I1.prototype,"disabled",void 0),q2([(0,bt.Cb)()],I1.prototype,"target",void 0),q2([(0,bt.Cb)()],I1.prototype,"token",void 0),q2([(0,bt.Cb)()],I1.prototype,"onSetAmount",void 0),q2([(0,bt.Cb)()],I1.prototype,"onSetMaxValue",void 0),I1=q2([(0,Xt.customElement)("w3m-convert-input")],I1);const vJe=Ke.iv`
  wui-icon-link[data-hidden='true'] {
    opacity: 0 !important;
    pointer-events: none;
  }
`;var xy=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};function Xee(){const t=ue.RouterController.state.data?.connector?.name,n=ue.RouterController.state.data?.wallet?.name,e=ue.RouterController.state.data?.network?.name,i=n??t,r=ue.ConnectorController.getConnectors();return{Connect:`Connect ${1===r.length&&"w3m-email"===r[0]?.id?"Email":""} Wallet`,Account:void 0,AccountSettings:void 0,ConnectingExternal:i??"Connect Wallet",ConnectingWalletConnect:i??"WalletConnect",ConnectingSiwe:"Sign In",Networks:"Choose Network",SwitchNetwork:e??"Switch Network",AllWallets:"All Wallets",WhatIsANetwork:"What is a network?",WhatIsAWallet:"What is a wallet?",GetWallet:"Get a wallet",Downloads:i?`Get ${i}`:"Downloads",EmailVerifyOtp:"Confirm Email",EmailVerifyDevice:"Register Device",ApproveTransaction:"Approve Transaction",Transactions:"Activity",UpgradeEmailWallet:"Upgrade your Wallet",UpgradeToSmartAccount:void 0,UpdateEmailWallet:"Edit Email",UpdateEmailPrimaryOtp:"Confirm Current Email",UpdateEmailSecondaryOtp:"Confirm New Email",UnsupportedChain:"Switch Network",OnRampProviders:"Choose Provider",OnRampActivity:"Activity",WhatIsABuy:"What is Buy?",BuyInProgress:"Buy",OnRampTokenSelect:"Select Token",OnRampFiatSelect:"Select Currency",WalletReceive:"Receive",WalletCompatibleNetworks:"Compatible Networks",WalletSend:"Send",WalletSendPreview:"Review send",WalletSendSelectToken:"Select Token"}}let Pd=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.heading=Xee()[ue.RouterController.state.view],this.buffering=!1,this.showBack=!1,this.unsubscribe.push(ue.RouterController.subscribeKey("view",n=>{this.onViewChange(n),this.onHistoryChange()}),ue.ConnectionController.subscribeKey("buffering",n=>this.buffering=n))}disconnectCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy`
      <wui-flex .padding=${this.getPadding()} justifyContent="space-between" alignItems="center">
        ${this.dynamicButtonTemplate()} ${this.titleTemplate()}
        <wui-icon-link
          ?disabled=${this.buffering}
          icon="close"
          @click=${this.onClose.bind(this)}
          data-testid="w3m-header-close"
        ></wui-icon-link>
      </wui-flex>
      ${this.separatorTemplate()}
    `}onWalletHelp(){ue.Xs.sendEvent({type:"track",event:"CLICK_WALLET_HELP"}),ue.RouterController.push("WhatIsAWallet")}onClose(){return(0,Ge.Z)(function*(){if(ue.OptionsController.state.isSiweEnabled){const{SIWEController:n}=yield $.e(632).then($.bind($,4632));"success"!==n.state.status&&(yield ue.ConnectionController.disconnect())}ue.IN.close()})()}titleTemplate(){return Ke.dy`<wui-text variant="paragraph-700" color="fg-100">${this.heading}</wui-text>`}dynamicButtonTemplate(){const{view:n}=ue.RouterController.state,e="Connect"===n;return this.showBack&&"ApproveTransaction"!==n&&"UpgradeToSmartAccount"!==n?Ke.dy`<wui-icon-link
        id="dynamic"
        icon="chevronLeft"
        ?disabled=${this.buffering}
        @click=${this.onGoBack.bind(this)}
      ></wui-icon-link>`:Ke.dy`<wui-icon-link
      data-hidden=${!e}
      id="dynamic"
      icon="helpCircle"
      @click=${this.onWalletHelp.bind(this)}
    ></wui-icon-link>`}separatorTemplate(){return this.heading?Ke.dy`<wui-separator></wui-separator>`:null}getPadding(){return this.heading?["l","2l","l","2l"]:["l","2l","0","2l"]}onViewChange(n){var e=this;return(0,Ge.Z)(function*(){const i=e.shadowRoot?.querySelector("wui-text");if(i){const r=Xee()[n];yield i.animate([{opacity:1},{opacity:0}],{duration:200,fill:"forwards",easing:"ease"}).finished,e.heading=r,i.animate([{opacity:0},{opacity:1}],{duration:200,fill:"forwards",easing:"ease"})}})()}onHistoryChange(){var n=this;return(0,Ge.Z)(function*(){const{history:e}=ue.RouterController.state,i=n.shadowRoot?.querySelector("#dynamic");e.length>1&&!n.showBack&&i?(yield i.animate([{opacity:1},{opacity:0}],{duration:200,fill:"forwards",easing:"ease"}).finished,n.showBack=!0,i.animate([{opacity:0},{opacity:1}],{duration:200,fill:"forwards",easing:"ease"})):e.length<=1&&n.showBack&&i&&(yield i.animate([{opacity:1},{opacity:0}],{duration:200,fill:"forwards",easing:"ease"}).finished,n.showBack=!1,i.animate([{opacity:0},{opacity:1}],{duration:200,fill:"forwards",easing:"ease"}))})()}onGoBack(){"ConnectingSiwe"===ue.RouterController.state.view?ue.RouterController.push("Connect"):ue.RouterController.goBack()}};Pd.styles=[vJe],xy([(0,bt.SB)()],Pd.prototype,"heading",void 0),xy([(0,bt.SB)()],Pd.prototype,"buffering",void 0),xy([(0,bt.SB)()],Pd.prototype,"showBack",void 0),Pd=xy([(0,Xt.customElement)("w3m-header")],Pd);var Qee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let YA=class extends Ke.oi{constructor(){super(...arguments),this.data=[]}render(){return Ke.dy`
      <wui-flex flexDirection="column" alignItems="center" gap="l">
        ${this.data.map(n=>Ke.dy`
            <wui-flex flexDirection="column" alignItems="center" gap="xl">
              <wui-flex flexDirection="row" justifyContent="center" gap="1xs">
                ${n.images.map(e=>Ke.dy`<wui-visual name=${e}></wui-visual>`)}
              </wui-flex>
            </wui-flex>
            <wui-flex flexDirection="column" alignItems="center" gap="xxs">
              <wui-text variant="paragraph-500" color="fg-100" align="center">
                ${n.title}
              </wui-text>
              <wui-text variant="small-500" color="fg-200" align="center">${n.text}</wui-text>
            </wui-flex>
          `)}
      </wui-flex>
    `}};Qee([(0,bt.Cb)({type:Array})],YA.prototype,"data",void 0),YA=Qee([(0,Xt.customElement)("w3m-help-widget")],YA);const yJe=Ke.iv`
  :host {
    width: 100%;
  }

  wui-loading-spinner {
    position: absolute;
    top: 50%;
    right: 20px;
    transform: translateY(-50%);
  }

  .currency-container {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    right: var(--wui-spacing-1xs);
    height: 40px;
    padding: var(--wui-spacing-xs) var(--wui-spacing-1xs) var(--wui-spacing-xs)
      var(--wui-spacing-xs);
    min-width: 95px;
    border-radius: var(--FULL, 1000px);
    border: 1px solid var(--wui-gray-glass-002);
    background: var(--wui-gray-glass-002);
    cursor: pointer;
  }

  .currency-container > wui-image {
    height: 24px;
    width: 24px;
    border-radius: 50%;
  }
`;var tu=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let zl=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.type="Token",this.value=0,this.currencies=[],this.selectedCurrency=this.currencies?.[0],this.currencyImages=ue.WM.state.currencyImages,this.tokenImages=ue.WM.state.tokenImages,this.unsubscribe.push(ue.ph.subscribeKey("purchaseCurrency",n=>{!n||"Fiat"===this.type||(this.selectedCurrency=this.formatPurchaseCurrency(n))}),ue.ph.subscribeKey("paymentCurrency",n=>{!n||"Token"===this.type||(this.selectedCurrency=this.formatPaymentCurrency(n))}),ue.ph.subscribe(n=>{this.currencies="Fiat"===this.type?n.purchaseCurrencies.map(this.formatPurchaseCurrency):n.paymentCurrencies.map(this.formatPaymentCurrency)}),ue.WM.subscribe(n=>{this.currencyImages={...n.currencyImages},this.tokenImages={...n.tokenImages}}))}firstUpdated(){ue.ph.getAvailableCurrencies()}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){const n=this.selectedCurrency?.symbol||"";return Ke.dy` <wui-input-text type="number" size="lg" value=${this.value}>
      ${this.selectedCurrency?Ke.dy` <wui-flex
            class="currency-container"
            justifyContent="space-between"
            alignItems="center"
            gap="xxs"
            @click=${()=>ue.IN.open({view:`OnRamp${this.type}Select`})}
          >
            <wui-image src=${jn(this.currencyImages[n]||this.tokenImages[n])}></wui-image>
            <wui-text color="fg-100"> ${this.selectedCurrency.symbol} </wui-text>
          </wui-flex>`:Ke.dy`<wui-loading-spinner></wui-loading-spinner>`}
    </wui-input-text>`}formatPaymentCurrency(n){return{name:n.id,symbol:n.id}}formatPurchaseCurrency(n){return{name:n.name,symbol:n.symbol}}};zl.styles=yJe,tu([(0,bt.Cb)({type:String})],zl.prototype,"type",void 0),tu([(0,bt.Cb)({type:Number})],zl.prototype,"value",void 0),tu([(0,bt.SB)()],zl.prototype,"currencies",void 0),tu([(0,bt.SB)()],zl.prototype,"selectedCurrency",void 0),tu([(0,bt.SB)()],zl.prototype,"currencyImages",void 0),tu([(0,bt.SB)()],zl.prototype,"tokenImages",void 0),zl=tu([(0,Xt.customElement)("w3m-swap-input")],zl);const _Je=Ke.iv`
  wui-flex {
    background-color: var(--wui-gray-glass-005);
  }

  a {
    text-decoration: none;
    color: var(--wui-color-fg-175);
    font-weight: 500;
  }
`;let KA=class extends Ke.oi{render(){const{termsConditionsUrl:n,privacyPolicyUrl:e}=ue.OptionsController.state;return n||e?Ke.dy`
      <wui-flex .padding=${["m","s","s","s"]} justifyContent="center">
        <wui-text color="fg-250" variant="small-400" align="center">
          By connecting your wallet, you agree to our <br />
          ${this.termsTemplate()} ${this.andTemplate()} ${this.privacyTemplate()}
        </wui-text>
      </wui-flex>
    `:null}andTemplate(){const{termsConditionsUrl:n,privacyPolicyUrl:e}=ue.OptionsController.state;return n&&e?"and":""}termsTemplate(){const{termsConditionsUrl:n}=ue.OptionsController.state;return n?Ke.dy`<a href=${n}>Terms of Service</a>`:null}privacyTemplate(){const{privacyPolicyUrl:n}=ue.OptionsController.state;return n?Ke.dy`<a href=${n}>Privacy Policy</a>`:null}};KA.styles=[_Je],KA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-legal-footer")],KA);const wJe=Ke.iv`
  :host {
    display: block;
    padding: 0 var(--wui-spacing-xl) var(--wui-spacing-xl);
  }
`;var Jee=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Ty=class extends Ke.oi{constructor(){super(...arguments),this.wallet=void 0}render(){if(!this.wallet)return this.style.display="none",null;const{name:n,app_store:e,play_store:i,chrome_store:r,homepage:s}=this.wallet,a=ue.j1.isMobile(),o=ue.j1.isIos(),c=ue.j1.isAndroid(),l=[e,i,s,r].filter(Boolean).length>1,u=Xt.UiHelperUtil.getTruncateString({string:n,charsStart:12,charsEnd:0,truncate:"end"});return l&&!a?Ke.dy`
        <wui-cta-button
          label=${`Don't have ${u}?`}
          buttonLabel="Get"
          @click=${()=>ue.RouterController.push("Downloads",{wallet:this.wallet})}
        ></wui-cta-button>
      `:!l&&s?Ke.dy`
        <wui-cta-button
          label=${`Don't have ${u}?`}
          buttonLabel="Get"
          @click=${this.onHomePage.bind(this)}
        ></wui-cta-button>
      `:e&&o?Ke.dy`
        <wui-cta-button
          label=${`Don't have ${u}?`}
          buttonLabel="Get"
          @click=${this.onAppStore.bind(this)}
        ></wui-cta-button>
      `:i&&c?Ke.dy`
        <wui-cta-button
          label=${`Don't have ${u}?`}
          buttonLabel="Get"
          @click=${this.onPlayStore.bind(this)}
        ></wui-cta-button>
      `:(this.style.display="none",null)}onAppStore(){this.wallet?.app_store&&ue.j1.openHref(this.wallet.app_store,"_blank")}onPlayStore(){this.wallet?.play_store&&ue.j1.openHref(this.wallet.play_store,"_blank")}onHomePage(){this.wallet?.homepage&&ue.j1.openHref(this.wallet.homepage,"_blank")}};Ty.styles=[wJe],Jee([(0,bt.Cb)({type:Object})],Ty.prototype,"wallet",void 0),Ty=Jee([(0,Xt.customElement)("w3m-mobile-download-links")],Ty);const CJe=Ke.iv`
  wui-flex {
    border-top: 1px solid var(--wui-gray-glass-005);
  }

  a {
    text-decoration: none;
    color: var(--wui-color-fg-175);
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--wui-spacing-3xs);
  }
`;let XA=class extends Ke.oi{render(){const{termsConditionsUrl:n,privacyPolicyUrl:e}=ue.OptionsController.state;return n||e?Ke.dy`
      <wui-flex
        .padding=${["m","s","s","s"]}
        flexDirection="column"
        alignItems="center"
        justifyContent="center"
        gap="s"
      >
        <wui-text color="fg-250" variant="small-400" align="center">
          We work with the best providers to give you the lowest fees and best support. More options
          coming soon!
        </wui-text>

        ${this.howDoesItWorkTemplate()}
      </wui-flex>
    `:null}howDoesItWorkTemplate(){return Ke.dy` <wui-link @click=${this.onWhatIsBuy.bind(this)}>
      <wui-icon size="xs" color="accent-100" slot="iconLeft" name="helpCircle"></wui-icon>
      How does it work?
    </wui-link>`}onWhatIsBuy(){ue.RouterController.push("WhatIsABuy")}};XA.styles=[CJe],XA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-onramp-providers-footer")],XA);const TJe=Ke.iv`
  :host {
    display: block;
    position: absolute;
    opacity: 0;
    pointer-events: none;
    top: 11px;
    left: 50%;
    width: max-content;
  }
`;var ete=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};const MJe={success:{backgroundColor:"success-100",iconColor:"success-100",icon:"checkmark"},error:{backgroundColor:"error-100",iconColor:"error-100",icon:"close"}};let My=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.timeout=void 0,this.open=ue.SnackController.state.open,this.unsubscribe.push(ue.SnackController.subscribeKey("open",n=>{this.open=n,this.onOpen()}))}disconnectedCallback(){clearTimeout(this.timeout),this.unsubscribe.forEach(n=>n())}render(){const{message:n,variant:e}=ue.SnackController.state,i=MJe[e];return Ke.dy`
      <wui-snackbar
        message=${n}
        backgroundColor=${i.backgroundColor}
        iconColor=${i.iconColor}
        icon=${i.icon}
      ></wui-snackbar>
    `}onOpen(){clearTimeout(this.timeout),this.open?(this.animate([{opacity:0,transform:"translateX(-50%) scale(0.85)"},{opacity:1,transform:"translateX(-50%) scale(1)"}],{duration:150,fill:"forwards",easing:"ease"}),this.timeout=setTimeout(()=>ue.SnackController.hide(),2500)):this.animate([{opacity:1,transform:"translateX(-50%) scale(1)"},{opacity:0,transform:"translateX(-50%) scale(0.85)"}],{duration:150,fill:"forwards",easing:"ease"})}};My.styles=TJe,ete([(0,bt.SB)()],My.prototype,"open",void 0),My=ete([(0,Xt.customElement)("w3m-snackbar")],My);const kJe=Ke.iv`
  wui-separator {
    margin: var(--wui-spacing-s) calc(var(--wui-spacing-s) * -1);
    width: calc(100% + var(--wui-spacing-s) * 2);
  }

  wui-email-input {
    width: 100%;
  }

  form {
    width: 100%;
    display: block;
    position: relative;
  }

  wui-icon-link,
  wui-loading-spinner {
    position: absolute;
    top: 21px;
    transform: translateY(-50%);
  }

  wui-icon-link {
    right: var(--wui-spacing-xs);
  }

  wui-loading-spinner {
    right: var(--wui-spacing-m);
  }
`;var Wh=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let nu=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.formRef=vy(),this.connectors=ue.ConnectorController.state.connectors,this.email="",this.loading=!1,this.error="",this.unsubscribe.push(ue.ConnectorController.subscribeKey("connectors",n=>this.connectors=n))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}firstUpdated(){this.formRef.value?.addEventListener("keydown",n=>{"Enter"===n.key&&this.onSubmitEmail(n)})}render(){const n=this.connectors.length>1;return this.connectors.find(i=>"EMAIL"===i.type)?Ke.dy`
      <form ${yy(this.formRef)} @submit=${this.onSubmitEmail.bind(this)}>
        <wui-email-input
          @focus=${this.onFocusEvent.bind(this)}
          .disabled=${this.loading}
          @inputChange=${this.onEmailInputChange.bind(this)}
          .errorMessage=${this.error}
        >
        </wui-email-input>

        ${this.submitButtonTemplate()}${this.loadingTemplate()}
        <input type="submit" hidden />
      </form>

      ${n?Ke.dy`<wui-separator text="or"></wui-separator>`:null}
    `:null}submitButtonTemplate(){return!this.loading&&this.email.length>3?Ke.dy`
          <wui-icon-link
            size="sm"
            icon="chevronRight"
            iconcolor="accent-100"
            @click=${this.onSubmitEmail.bind(this)}
          >
          </wui-icon-link>
        `:null}loadingTemplate(){return this.loading?Ke.dy`<wui-loading-spinner size="md" color="accent-100"></wui-loading-spinner>`:null}onEmailInputChange(n){this.email=n.detail.trim(),this.error=""}onSubmitEmail(n){var e=this;return(0,Ge.Z)(function*(){try{if(e.loading)return;e.loading=!0,n.preventDefault();const i=ue.ConnectorController.getEmailConnector();if(!i)throw new Error("w3m-email-login-widget: Email connector not found");const{action:r}=yield i.provider.connectEmail({email:e.email});ue.Xs.sendEvent({type:"track",event:"EMAIL_SUBMITTED"}),"VERIFY_OTP"===r?(ue.Xs.sendEvent({type:"track",event:"EMAIL_VERIFICATION_CODE_SENT"}),ue.RouterController.push("EmailVerifyOtp",{email:e.email})):"VERIFY_DEVICE"===r&&ue.RouterController.push("EmailVerifyDevice",{email:e.email})}catch(i){ue.j1.parseError(i)?.includes("Invalid email")?e.error="Invalid email. Try again.":ue.SnackController.showError(i)}finally{e.loading=!1}})()}onFocusEvent(){ue.Xs.sendEvent({type:"track",event:"EMAIL_LOGIN_SELECTED"})}};nu.styles=kJe,Wh([(0,bt.SB)()],nu.prototype,"connectors",void 0),Wh([(0,bt.SB)()],nu.prototype,"email",void 0),Wh([(0,bt.SB)()],nu.prototype,"loading",void 0),Wh([(0,bt.SB)()],nu.prototype,"error",void 0),nu=Wh([(0,Xt.customElement)("w3m-email-login-widget")],nu);const SJe=Ke.iv`
  wui-flex {
    width: 100%;
  }

  :host > wui-flex:first-child {
    transform: translateY(calc(var(--wui-spacing-xxs) * -1));
  }

  wui-icon-link {
    margin-right: calc(var(--wui-icon-box-size-md) * -1);
  }

  wui-notice-card {
    margin-bottom: var(--wui-spacing-3xs);
  }

  w3m-transactions-view {
    max-height: 200px;
  }

  .tab-content-container {
    height: 300px;
    overflow-y: auto;
    overflow-x: hidden;
    scrollbar-width: none;
  }

  .account-button {
    width: auto;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--wui-spacing-s);
    height: 48px;
    padding: var(--wui-spacing-xs);
    padding-right: var(--wui-spacing-s);
    box-shadow: inset 0 0 0 1px var(--wui-gray-glass-002);
    background-color: var(--wui-gray-glass-002);
    border-radius: 24px;
    transaction: background-color 0.2s linear;
  }

  .account-button:hover {
    background-color: var(--wui-gray-glass-005);
  }

  .avatar-container {
    position: relative;
  }

  wui-avatar.avatar {
    width: 32px;
    height: 32px;
    box-shadow: 0 0 0 2px var(--wui-gray-glass-005);
  }

  wui-avatar.network-avatar {
    width: 16px;
    height: 16px;
    position: absolute;
    left: 100%;
    top: 100%;
    transform: translate(-75%, -75%);
    box-shadow: 0 0 0 2px var(--wui-gray-glass-005);
  }

  .account-links {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .account-links wui-flex {
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 1;
    background: red;
    align-items: center;
    justify-content: center;
    height: 48px;
    padding: 10px;
    flex: 1 0 0;
    border-radius: var(--XS, 16px);
    border: 1px solid var(--dark-accent-glass-010, rgba(71, 161, 255, 0.1));
    background: var(--dark-accent-glass-010, rgba(71, 161, 255, 0.1));
    transition: background-color var(--wui-ease-out-power-1) var(--wui-duration-md);
    will-change: background-color;
  }

  .account-links wui-flex:hover {
    background: var(--dark-accent-glass-015, rgba(71, 161, 255, 0.15));
  }

  .account-links wui-flex wui-icon {
    width: var(--S, 20px);
    height: var(--S, 20px);
  }

  .account-links wui-flex wui-icon svg path {
    stroke: #47a1ff;
  }
`;var e0=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Rc=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.address=ue.AccountController.state.address,this.profileImage=ue.AccountController.state.profileImage,this.profileName=ue.AccountController.state.profileName,this.network=ue.NetworkController.state.caipNetwork,this.disconnecting=!1,this.balance=ue.AccountController.state.balance,this.balanceSymbol=ue.AccountController.state.balanceSymbol,this.unsubscribe.push(ue.AccountController.subscribe(n=>{n.address?(this.address=n.address,this.profileImage=n.profileImage,this.profileName=n.profileName,this.balance=n.balance,this.balanceSymbol=n.balanceSymbol):this.disconnecting||ue.SnackController.showError("Account not found")}),ue.NetworkController.subscribeKey("caipNetwork",n=>{n?.id&&(this.network=n)}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){if(!this.address)throw new Error("w3m-account-view: No account provided");const n=ue.fz.getNetworkImage(this.network);return Ke.dy`<wui-flex
        flexDirection="column"
        .padding=${["0","xl","m","xl"]}
        alignItems="center"
        gap="l"
      >
        <wui-avatar
          alt=${jn(this.address)}
          address=${jn(this.address)}
          imageSrc=${jn(null===this.profileImage?void 0:this.profileImage)}
        ></wui-avatar>
        <wui-flex flexDirection="column" alignItems="center">
          <wui-flex gap="3xs" alignItems="center" justifyContent="center">
            <wui-text variant="medium-title-600" color="fg-100">
              ${Xt.UiHelperUtil.getTruncateString(this.profileName?{string:this.profileName,charsStart:20,charsEnd:0,truncate:"end"}:{string:this.address?this.address:"",charsStart:4,charsEnd:4,truncate:"middle"})}
            </wui-text>
            <wui-icon-link
              size="md"
              icon="copy"
              iconColor="fg-200"
              @click=${this.onCopyAddress}
            ></wui-icon-link>
          </wui-flex>
          <wui-text variant="paragraph-500" color="fg-200"
            >${ue.j1.formatBalance(this.balance,this.balanceSymbol)}</wui-text
          >
        </wui-flex>
        ${this.explorerBtnTemplate()}
      </wui-flex>

      <wui-flex flexDirection="column" gap="xs" .padding=${["0","s","s","s"]}>
        ${this.emailCardTemplate()} ${this.emailBtnTemplate()}

        <wui-list-item
          .variant=${n?"image":"icon"}
          iconVariant="overlay"
          icon="networkPlaceholder"
          imageSrc=${jn(n)}
          ?chevron=${this.isAllowedNetworkSwitch()}
          @click=${this.onNetworks.bind(this)}
          data-testid="w3m-account-select-network"
        >
          <wui-text variant="paragraph-500" color="fg-100">
            ${this.network?.name??"Unknown"}
          </wui-text>
        </wui-list-item>
        ${this.onrampTemplate()}
        <wui-list-item
          iconVariant="blue"
          icon="swapHorizontalMedium"
          iconSize="sm"
          ?chevron=${!0}
          @click=${this.onTransactions.bind(this)}
        >
          <wui-text variant="paragraph-500" color="fg-100">Activity</wui-text>
        </wui-list-item>
        <wui-list-item
          variant="icon"
          iconVariant="overlay"
          icon="disconnect"
          ?chevron=${!1}
          .loading=${this.disconnecting}
          @click=${this.onDisconnect.bind(this)}
          data-testid="disconnect-button"
        >
          <wui-text variant="paragraph-500" color="fg-200">Disconnect</wui-text>
        </wui-list-item>
      </wui-flex>`}onrampTemplate(){const{enableOnramp:n}=ue.OptionsController.state;return n?Ke.dy`
      <wui-list-item
        iconVariant="blue"
        icon="card"
        ?chevron=${!0}
        @click=${this.handleClickPay.bind(this)}
      >
        <wui-text variant="paragraph-500" color="fg-100">Buy crypto</wui-text>
      </wui-list-item>
    `:null}emailCardTemplate(){const n=ue.MO.getConnectedConnector(),e=ue.ConnectorController.getEmailConnector(),{origin:i}=location;return!e||"EMAIL"!==n||i.includes(ue.bq.SECURE_SITE)?null:Ke.dy`
      <wui-notice-card
        @click=${this.onGoToUpgradeView.bind(this)}
        label="Upgrade your wallet"
        description="Transition to a self-custodial wallet"
        icon="wallet"
        data-testid="w3m-wallet-upgrade-card"
      ></wui-notice-card>
    `}handleClickPay(){ue.RouterController.push("OnRampProviders")}explorerBtnTemplate(){const{addressExplorerUrl:n}=ue.AccountController.state;return n?Ke.dy`
      <wui-button size="sm" variant="shade" @click=${this.onExplorer.bind(this)}>
        <wui-icon size="sm" color="inherit" slot="iconLeft" name="compass"></wui-icon>
        Block Explorer
        <wui-icon size="sm" color="inherit" slot="iconRight" name="externalLink"></wui-icon>
      </wui-button>
    `:null}emailBtnTemplate(){const n=ue.MO.getConnectedConnector(),e=ue.ConnectorController.getEmailConnector();if(!e||"EMAIL"!==n)return null;const i=e.provider.getEmail()??"";return Ke.dy`
      <wui-list-item
        variant="icon"
        iconVariant="overlay"
        icon="mail"
        iconSize="sm"
        ?chevron=${!0}
        @click=${()=>this.onGoToUpdateEmail(i)}
      >
        <wui-text variant="paragraph-500" color="fg-100">${i}</wui-text>
      </wui-list-item>
    `}isAllowedNetworkSwitch(){const{requestedCaipNetworks:n}=ue.NetworkController.state,e=!!n&&n.length>1,i=n?.find(({id:r})=>r===this.network?.id);return e||!i}onCopyAddress(){try{this.address&&(ue.j1.copyToClopboard(this.address),ue.SnackController.showSuccess("Address copied"))}catch{ue.SnackController.showError("Failed to copy")}}onNetworks(){this.isAllowedNetworkSwitch()&&(ue.Xs.sendEvent({type:"track",event:"CLICK_NETWORKS"}),ue.RouterController.push("Networks"))}onTransactions(){ue.Xs.sendEvent({type:"track",event:"CLICK_TRANSACTIONS"}),ue.RouterController.push("Transactions")}onDisconnect(){var n=this;return(0,Ge.Z)(function*(){try{n.disconnecting=!0,yield ue.ConnectionController.disconnect(),ue.Xs.sendEvent({type:"track",event:"DISCONNECT_SUCCESS"}),ue.IN.close()}catch{ue.Xs.sendEvent({type:"track",event:"DISCONNECT_ERROR"}),ue.SnackController.showError("Failed to disconnect")}finally{n.disconnecting=!1}})()}onExplorer(){const{addressExplorerUrl:n}=ue.AccountController.state;n&&ue.j1.openHref(n,"_blank")}onGoToUpgradeView(){ue.Xs.sendEvent({type:"track",event:"EMAIL_UPGRADE_FROM_MODAL"}),ue.RouterController.push("UpgradeEmailWallet")}onGoToUpdateEmail(n){ue.RouterController.push("UpdateEmailWallet",{email:n})}};Rc.styles=SJe,e0([(0,bt.SB)()],Rc.prototype,"address",void 0),e0([(0,bt.SB)()],Rc.prototype,"profileImage",void 0),e0([(0,bt.SB)()],Rc.prototype,"profileName",void 0),e0([(0,bt.SB)()],Rc.prototype,"network",void 0),e0([(0,bt.SB)()],Rc.prototype,"disconnecting",void 0),e0([(0,bt.SB)()],Rc.prototype,"balance",void 0),e0([(0,bt.SB)()],Rc.prototype,"balanceSymbol",void 0),Rc=e0([(0,Xt.customElement)("w3m-account-default-widget")],Rc);const EJe=Ke.iv`
  wui-flex {
    width: 100%;
  }

  wui-promo {
    position: absolute;
    top: -32px;
  }

  wui-profile-button {
    margin-top: calc(-1 * var(--wui-spacing-2l));
  }

  wui-promo + wui-profile-button {
    margin-top: var(--wui-spacing-2l);
  }

  wui-tooltip-select {
    width: 100%;
  }

  wui-tabs {
    width: 100%;
  }

  .contentContainer {
    height: 280px;
  }

  .contentContainer > wui-icon-box {
    width: 40px;
    height: 40px;
    border-radius: var(--wui-border-radius-xxs);
  }

  .contentContainer > .textContent {
    width: 65%;
  }
`,AJe_ACCOUNT_TABS=[{label:"Tokens"},{label:"NFTs"},{label:"Activity"}];var t0=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Lc=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.address=ue.AccountController.state.address,this.profileImage=ue.AccountController.state.profileImage,this.profileName=ue.AccountController.state.profileName,this.smartAccountDeployed=ue.AccountController.state.smartAccountDeployed,this.network=ue.NetworkController.state.caipNetwork,this.currentTab=ue.AccountController.state.currentTab,this.tokenBalance=ue.AccountController.state.tokenBalance,this.unsubscribe.push(ue.AccountController.subscribe(n=>{n.address?(this.address=n.address,this.profileImage=n.profileImage,this.profileName=n.profileName,this.currentTab=n.currentTab,this.tokenBalance=n.tokenBalance,this.smartAccountDeployed=n.smartAccountDeployed):ue.IN.close()}),ue.NetworkController.subscribe(n=>{this.network=n.caipNetwork}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){if(!this.address)throw new Error("w3m-account-view: No account provided");const n=ue.fz.getNetworkImage(this.network);return Ke.dy`<wui-flex
      flexDirection="column"
      .padding=${["0","xl","m","xl"]}
      alignItems="center"
      gap="m"
    >
      ${this.activateAccountTemplate()}
      <wui-profile-button
        @click=${this.onProfileButtonClick.bind(this)}
        address=${jn(this.address)}
        networkSrc=${jn(n)}
        icon="chevronBottom"
        avatarSrc=${jn(this.profileImage?this.profileImage:void 0)}
        ?isprofilename=${!!this.profileName}
      ></wui-profile-button>
      ${this.tokenBalanceTemplate()}
      <wui-flex gap="s">
        <wui-tooltip-select
          @click=${this.onBuyClick.bind(this)}
          text="Buy"
          icon="card"
        ></wui-tooltip-select>
        <wui-tooltip-select text="Convert" icon="recycleHorizontal"></wui-tooltip-select>
        <wui-tooltip-select
          @click=${this.onReceiveClick.bind(this)}
          text="Receive"
          icon="arrowBottomCircle"
        ></wui-tooltip-select>
        <wui-tooltip-select
          @click=${this.onSendClick.bind(this)}
          text="Send"
          icon="send"
        ></wui-tooltip-select>
      </wui-flex>

      <wui-tabs
        .onTabChange=${this.onTabChange.bind(this)}
        .activeTab=${this.currentTab}
        localTabWidth="104px"
        .tabs=${AJe_ACCOUNT_TABS}
      ></wui-tabs>
      ${this.listContentTemplate()}
    </wui-flex>`}listContentTemplate(){return 0===this.currentTab?Ke.dy`<w3m-account-tokens-widget></w3m-account-tokens-widget>`:1===this.currentTab?Ke.dy`<w3m-account-nfts-widget></w3m-account-nfts-widget>`:2===this.currentTab?Ke.dy`<w3m-account-activity-widget></w3m-account-activity-widget>`:Ke.dy`<w3m-account-tokens-widget></w3m-account-tokens-widget>`}tokenBalanceTemplate(){if(this.tokenBalance&&this.tokenBalance?.length>=0){const n=ue.j1.calculateBalance(this.tokenBalance),{dollars:e="0",pennies:i="00"}=ue.j1.formatTokenBalance(n);return Ke.dy`<wui-balance dollars=${e} pennies=${i}></wui-balance>`}return Ke.dy`<wui-balance dollars="0" pennies="00"></wui-balance>`}activateAccountTemplate(){const n=ue.NetworkController.checkIfSmartAccountEnabled(),e=es.getPreferredAccountType();return!n||e===wa.ACCOUNT_TYPES.SMART_ACCOUNT||this.smartAccountDeployed?null:Ke.dy` <wui-promo
      text=${"Activate your account"}
      @click=${this.onUpdateToSmartAccount.bind(this)}
      data-testid="activate-smart-account-promo"
    ></wui-promo>`}onTabChange(n){ue.AccountController.setCurrentTab(n)}onProfileButtonClick(){ue.RouterController.push("AccountSettings")}onBuyClick(){ue.RouterController.push("OnRampProviders")}onReceiveClick(){ue.RouterController.push("WalletReceive")}onSendClick(){ue.RouterController.push("WalletSend")}onUpdateToSmartAccount(){ue.RouterController.push("UpgradeToSmartAccount")}};Lc.styles=EJe,t0([(0,bt.SB)()],Lc.prototype,"address",void 0),t0([(0,bt.SB)()],Lc.prototype,"profileImage",void 0),t0([(0,bt.SB)()],Lc.prototype,"profileName",void 0),t0([(0,bt.SB)()],Lc.prototype,"smartAccountDeployed",void 0),t0([(0,bt.SB)()],Lc.prototype,"network",void 0),t0([(0,bt.SB)()],Lc.prototype,"currentTab",void 0),t0([(0,bt.SB)()],Lc.prototype,"tokenBalance",void 0),Lc=t0([(0,Xt.customElement)("w3m-account-wallet-features-widget")],Lc);const IJe=Ke.iv`
  :host {
    width: 100%;
    max-height: 280px;
    overflow: scroll;
    scrollbar-width: none;
  }
`;let QA=class extends Ke.oi{render(){return Ke.dy`<w3m-activity-list page="account"></w3m-activity-list>`}};QA.styles=IJe,QA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-account-activity-widget")],QA);const NJe=Ke.iv`
  .contentContainer {
    height: 280px;
  }

  .contentContainer > wui-icon-box {
    width: 40px;
    height: 40px;
    border-radius: var(--wui-border-radius-xxs);
  }

  .contentContainer > .textContent {
    width: 65%;
  }
`;let JA=class extends Ke.oi{render(){return Ke.dy`${this.nftTemplate()}`}nftTemplate(){return Ke.dy` <wui-flex
      class="contentContainer"
      alignItems="center"
      justifyContent="center"
      flexDirection="column"
      gap="l"
    >
      <wui-icon-box
        icon="wallet"
        size="inherit"
        iconColor="fg-200"
        backgroundColor="fg-200"
        iconSize="lg"
      ></wui-icon-box>
      <wui-flex
        class="textContent"
        gap="xs"
        flexDirection="column"
        justifyContent="center"
        flexDirection="column"
      >
        <wui-text variant="paragraph-500" align="center" color="fg-100">No NFTs yet</wui-text>
        <wui-text variant="small-400" align="center" color="fg-200"
          >Transfer from another wallets to get started</wui-text
        >
      </wui-flex>
      <wui-link @click=${this.onReceiveClick.bind(this)}>Receive NFTs</wui-link>
    </wui-flex>`}onReceiveClick(){ue.RouterController.push("WalletReceive")}};JA.styles=NJe,JA=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s}([(0,Xt.customElement)("w3m-account-nfts-widget")],JA);const LJe=Ke.iv`
  :host {
    width: 100%;
  }

  wui-flex {
    width: 100%;
  }

  .contentContainer {
    max-height: 280px;
    overflow: scroll;
    scrollbar-width: none;
  }
`;var tte=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let ky=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.tokenBalance=ue.AccountController.state.tokenBalance,this.unsubscribe.push(ue.AccountController.subscribe(n=>{this.tokenBalance=n.tokenBalance}))}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}firstUpdated(){ue.AccountController.fetchTokenBalance()}render(){return Ke.dy`${this.tokenTemplate()}`}tokenTemplate(){return this.tokenBalance&&this.tokenBalance?.length>0?Ke.dy`<wui-flex class="contentContainer" flexDirection="column" gap="xs">
        ${this.tokenItemTemplate()}
      </wui-flex>`:Ke.dy` <wui-flex flexDirection="column" gap="xs"
      ><wui-list-description
        @click=${this.onBuyClick.bind(this)}
        text="Buy Crypto"
        description="Easy with card or bank account"
        icon="card"
        iconColor="success-100"
        iconBackgroundColor="success-100"
        tag="popular"
      ></wui-list-description
      ><wui-list-description
        @click=${this.onReceiveClick.bind(this)}
        text="Receive funds"
        description="Transfer tokens on your wallet"
        icon="arrowBottomCircle"
        iconColor="fg-200"
        iconBackgroundColor="fg-200"
      ></wui-list-description
    ></wui-flex>`}tokenItemTemplate(){return this.tokenBalance?.map(n=>Ke.dy`<wui-list-token
          tokenName=${n.name}
          tokenImageUrl=${n.iconUrl}
          tokenAmount=${n.quantity.numeric}
          tokenValue=${n.value}
          tokenCurrency=${n.symbol}
        ></wui-list-token>`)}onReceiveClick(){ue.RouterController.push("WalletReceive")}onBuyClick(){ue.RouterController.push("OnRampProviders")}};ky.styles=LJe,tte([(0,bt.SB)()],ky.prototype,"tokenBalance",void 0),ky=tte([(0,Xt.customElement)("w3m-account-tokens-widget")],ky);const PJe=Ke.iv`
  :host {
    height: 100%;
  }

  .contentContainer {
    height: 280px;
  }

  .contentContainer > wui-icon-box {
    width: 40px;
    height: 40px;
    border-radius: var(--wui-border-radius-xxs);
  }

  .contentContainer > .textContent {
    width: 65%;
  }
`;var iu=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};const Sy="last-transaction";let Ol=class extends Ke.oi{constructor(){super(),this.unsubscribe=[],this.paginationObserver=void 0,this.page="activity",this.address=ue.AccountController.state.address,this.transactionsByYear=ue.sl.state.transactionsByYear,this.loading=ue.sl.state.loading,this.empty=ue.sl.state.empty,this.next=ue.sl.state.next,ue.sl.clearCursor(),this.unsubscribe.push(ue.AccountController.subscribe(n=>{n.isConnected&&this.address!==n.address&&(this.address=n.address,ue.sl.resetTransactions(),ue.sl.fetchTransactions(n.address))}),ue.sl.subscribe(n=>{this.transactionsByYear=n.transactionsByYear,this.loading=n.loading,this.empty=n.empty,this.next=n.next}))}firstUpdated(){ue.sl.fetchTransactions(this.address),this.createPaginationObserver()}updated(){this.setPaginationObserver()}disconnectedCallback(){this.unsubscribe.forEach(n=>n())}render(){return Ke.dy` ${this.empty?null:this.templateTransactionsByYear()}
    ${this.loading?this.templateLoading():null}
    ${!this.loading&&this.empty?this.templateEmpty():null}`}templateTransactionsByYear(){const n=Object.keys(this.transactionsByYear).sort().reverse();return n.map((e,i)=>{const r=i===n.length-1,s=parseInt(e,10);return new Array(12).fill(null).map((o,c)=>c).reverse().map(o=>{const c=Xt.TransactionUtil.getTransactionGroupTitle(s,o),l=this.transactionsByYear[s]?.[o];return l?Ke.dy`
          <wui-flex flexDirection="column">
            <wui-flex
              alignItems="center"
              flexDirection="row"
              .padding=${["xs","s","s","s"]}
            >
              <wui-text variant="paragraph-500" color="fg-200">${c}</wui-text>
            </wui-flex>
            <wui-flex flexDirection="column" gap="xs">
              ${this.templateTransactions(l,r)}
            </wui-flex>
          </wui-flex>
        `:null})})}templateRenderTransaction(n,e){const{date:i,descriptions:r,direction:s,isAllNFT:a,images:o,status:c,transfers:l,type:u}=this.getTransactionListItemProps(n),d=l?.length>1;return 2!==l?.length||a?d?l.map((y,I)=>{const D=Xt.TransactionUtil.getTransferDescription(y);return Ke.dy` <wui-transaction-list-item
          date=${i}
          direction=${y.direction}
          id=${e&&I===l.length-1&&this.next?Sy:""}
          status=${c}
          type=${u}
          .onlyDirectionIcon=${!0}
          .images=${[o[I]]}
          .descriptions=${[D]}
        ></wui-transaction-list-item>`}):Ke.dy`
      <wui-transaction-list-item
        date=${i}
        .direction=${s}
        id=${e&&this.next?Sy:""}
        status=${c}
        type=${u}
        .images=${o}
        .descriptions=${r}
      ></wui-transaction-list-item>
    `:Ke.dy`
        <wui-transaction-list-item
          date=${i}
          .direction=${s}
          id=${e&&this.next?Sy:""}
          status=${c}
          type=${u}
          .images=${o}
          .descriptions=${r}
        ></wui-transaction-list-item>
      `}templateTransactions(n,e){return n.map((i,r)=>Ke.dy`${this.templateRenderTransaction(i,e&&r===n.length-1)}`)}emptyStateActivity(){return Ke.dy`<wui-flex
      flexGrow="1"
      flexDirection="column"
      justifyContent="center"
      alignItems="center"
      .padding=${["3xl","xl","3xl","xl"]}
      gap="xl"
    >
      <wui-icon-box
        backgroundColor="glass-005"
        background="gray"
        iconColor="fg-200"
        icon="wallet"
        size="lg"
        ?border=${!0}
        borderColor="wui-color-bg-125"
      ></wui-icon-box>
      <wui-flex flexDirection="column" alignItems="center" gap="xs">
        <wui-text align="center" variant="paragraph-500" color="fg-100"
          >No Transactions yet</wui-text
        >
        <wui-text align="center" variant="small-500" color="fg-200"
          >Start trading on dApps <br />
          to grow your wallet!</wui-text
        >
      </wui-flex>
    </wui-flex>`}emptyStateAccount(){return Ke.dy`<wui-flex
      class="contentContainer"
      alignItems="center"
      justifyContent="center"
      flexDirection="column"
      gap="l"
    >
      <wui-icon-box
        icon="swapHorizontal"
        size="inherit"
        iconColor="fg-200"
        backgroundColor="fg-200"
        iconSize="lg"
      ></wui-icon-box>
      <wui-flex
        class="textContent"
        gap="xs"
        flexDirection="column"
        justifyContent="center"
        flexDirection="column"
      >
        <wui-text variant="paragraph-500" align="center" color="fg-100">No activity yet</wui-text>
        <wui-text variant="small-400" align="center" color="fg-200"
          >Your next transactions will appear here</wui-text
        >
      </wui-flex>
      <wui-link @click=${this.onReceiveClick.bind(this)}>Trade</wui-link>
    </wui-flex>`}templateEmpty(){return"account"===this.page?Ke.dy`${this.emptyStateAccount()}`:Ke.dy`${this.emptyStateActivity()}`}templateLoading(){return"activity"===this.page?Array(7).fill(Ke.dy` <wui-transaction-list-item-loader></wui-transaction-list-item-loader> `).map(n=>n):null}onReceiveClick(){ue.RouterController.push("WalletReceive")}createPaginationObserver(){const{projectId:n}=ue.OptionsController.state;this.paginationObserver=new IntersectionObserver(([e])=>{e?.isIntersecting&&!this.loading&&(ue.sl.fetchTransactions(this.address),ue.Xs.sendEvent({type:"track",event:"LOAD_MORE_TRANSACTIONS",properties:{address:this.address,projectId:n,cursor:this.next}}))},{}),this.setPaginationObserver()}setPaginationObserver(){this.paginationObserver?.disconnect();const n=this.shadowRoot?.querySelector(`#${Sy}`);n&&this.paginationObserver?.observe(n)}getTransactionListItemProps(n){const e=Dc.Em.formatDate(n?.metadata?.minedAt),i=Xt.TransactionUtil.getTransactionDescriptions(n),r=n?.transfers,s=n?.transfers?.[0],a=!!s&&n?.transfers?.every(c=>!!c.nft_info),o=Xt.TransactionUtil.getTransactionImages(r);return{date:e,direction:s?.direction,descriptions:i,isAllNFT:a,images:o,status:n.metadata?.status,transfers:r,type:n.metadata?.operationType}}};Ol.styles=PJe,iu([(0,bt.Cb)()],Ol.prototype,"page",void 0),iu([(0,bt.SB)()],Ol.prototype,"address",void 0),iu([(0,bt.SB)()],Ol.prototype,"transactionsByYear",void 0),iu([(0,bt.SB)()],Ol.prototype,"loading",void 0),iu([(0,bt.SB)()],Ol.prototype,"empty",void 0),iu([(0,bt.SB)()],Ol.prototype,"next",void 0),Ol=iu([(0,Xt.customElement)("w3m-activity-list")],Ol);const OJe=Ke.iv`
  :host {
    width: 100%;
    height: 100px;
    border-radius: var(--wui-border-radius-s);
    border: 1px solid var(--wui-gray-glass-002);
    background-color: var(--wui-gray-glass-002);
    transition: background-color var(--wui-ease-out-power-1) var(--wui-duration-lg);
    will-change: background-color;
  }

  :host(:hover) {
    background-color: var(--wui-gray-glass-005);
  }

  wui-flex {
    width: 100%;
    height: fit-content;
  }

  wui-button {
    width: 100%;
    display: flex;
    justify-content: flex-end;
  }
`;var eI=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let qh=class extends Ke.oi{render(){return Ke.dy` <wui-flex
      flexDirection="column"
      gap="4xs"
      .padding=${["xl","s","l","l"]}
    >
      <wui-flex alignItems="center">
        <wui-input-amount
          @inputChange=${this.onInputChange.bind(this)}
          ?disabled=${!this.token&&!0}
          .value=${this.sendTokenAmount?String(this.sendTokenAmount):""}
        ></wui-input-amount>
        ${this.buttonTemplate()}
      </wui-flex>
      <wui-flex alignItems="center" justifyContent="space-between">
        ${this.sendValueTemplate()}
        <wui-flex alignItems="center" gap="4xs" justifyContent="flex-end">
          ${this.maxAmountTemplate()} ${this.actionTemplate()}
        </wui-flex>
      </wui-flex>
    </wui-flex>`}buttonTemplate(){return this.token?Ke.dy`<wui-token-button
        text=${this.token.symbol}
        imageSrc=${this.token.iconUrl}
        @click=${this.handleSelectButtonClick.bind(this)}
        >Select token</wui-token-button
      >`:Ke.dy`<wui-button
      size="md"
      variant="accentBg"
      @click=${this.handleSelectButtonClick.bind(this)}
      >Select token</wui-button
    >`}handleSelectButtonClick(){ue.RouterController.push("WalletSendSelectToken")}sendValueTemplate(){return this.token&&this.sendTokenAmount?Ke.dy`<wui-text variant="small-400" color="fg-200">$${(this.token.price*this.sendTokenAmount).toFixed(2)}</wui-text>`:null}maxAmountTemplate(){return this.token?this.sendTokenAmount&&this.sendTokenAmount>Number(this.token.quantity.numeric)?Ke.dy` <wui-text variant="small-400" color="error-100">
          ${Xt.UiHelperUtil.roundNumber(Number(this.token.quantity.numeric),6,5)}
        </wui-text>`:Ke.dy` <wui-text variant="small-400" color="fg-200">
        ${Xt.UiHelperUtil.roundNumber(Number(this.token.quantity.numeric),6,5)}
      </wui-text>`:null}actionTemplate(){return this.token?this.sendTokenAmount&&this.sendTokenAmount>Number(this.token.quantity.numeric)?Ke.dy`<wui-link @click=${this.onBuyClick.bind(this)}>Buy</wui-link>`:Ke.dy`<wui-link @click=${this.onMaxClick.bind(this)}>Max</wui-link>`:null}onInputChange(n){ue.Si.setTokenAmount(n.detail)}onMaxClick(){this.token&&ue.Si.setTokenAmount(Number(this.token?.quantity.numeric))}onBuyClick(){ue.RouterController.push("OnRampProviders")}};qh.styles=OJe,eI([(0,bt.Cb)({type:Object})],qh.prototype,"token",void 0),eI([(0,bt.Cb)({type:Number})],qh.prototype,"sendTokenAmount",void 0),qh=eI([(0,Xt.customElement)("w3m-input-token")],qh);const HJe=Ke.iv`
  :host {
    width: 100%;
    height: 100px;
    border-radius: var(--wui-border-radius-s);
    border: 1px solid var(--wui-gray-glass-002);
    background-color: var(--wui-gray-glass-002);
    transition: background-color var(--wui-ease-out-power-1) var(--wui-duration-lg);
    will-change: background-color;
    position: relative;
  }

  :host(:hover) {
    background-color: var(--wui-gray-glass-005);
  }

  wui-flex {
    width: 100%;
    height: fit-content;
  }

  wui-button {
    display: ruby;
    color: var(--wui-color-fg-100);
    margin: 0 var(--wui-spacing-xs);
  }

  .instruction {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
  }

  textarea {
    background: transparent;
    width: 100%;
    font-family: var(--w3m-font-family);
    font-size: var(--wui-font-size-medium);
    font-style: normal;
    font-weight: var(--wui-font-weight-light);
    line-height: 130%;
    letter-spacing: var(--wui-letter-spacing-medium);
    color: var(--wui-color-fg-100);
    caret-color: var(--wui-color-accent-100);
    box-sizing: border-box;
    -webkit-appearance: none;
    -moz-appearance: textfield;
    padding: 0px;
    border: none;
    outline: none;
    appearance: none;
    resize: none;
    overflow: hidden;
  }
`;var tI=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Gh=class extends Ke.oi{constructor(){super(...arguments),this.inputElementRef=vy(),this.instructionElementRef=vy(),this.instructionHidden=!!this.receiverAddress}firstUpdated(){this.receiverAddress&&(this.instructionHidden=!0),this.checkHidden()}render(){return Ke.dy` <wui-flex
      @click=${this.onBoxClick.bind(this)}
      flexDirection="column"
      justifyContent="center"
      gap="4xs"
      .padding=${["2xl","l","xl","l"]}
    >
      <wui-text
        ${yy(this.instructionElementRef)}
        class="instruction"
        color="fg-300"
        variant="medium-400"
      >
        Type or
        <wui-button
          size="sm"
          variant="shade"
          iconLeft="copy"
          @click=${this.onPasteClick.bind(this)}
        >
          <wui-icon size="sm" color="inherit" slot="iconLeft" name="copy"></wui-icon>
          Paste
        </wui-button>
        address
      </wui-text>
      <textarea
        ?disabled=${!this.instructionHidden}
        ${yy(this.inputElementRef)}
        @input=${this.onInputChange.bind(this)}
        @blur=${this.onBlur.bind(this)}
        .value=${this.receiverAddress??""}
        autocomplete="off"
      >
${this.receiverAddress??""}</textarea
      >
    </wui-flex>`}focusInput(){var n=this;return(0,Ge.Z)(function*(){n.instructionElementRef.value&&(n.instructionHidden=!0,yield n.toggleInstructionFocus(!1),n.instructionElementRef.value.style.pointerEvents="none",n.inputElementRef.value?.focus(),n.inputElementRef.value&&(n.inputElementRef.value.selectionStart=n.inputElementRef.value.selectionEnd=n.inputElementRef.value.value.length))})()}focusInstruction(){var n=this;return(0,Ge.Z)(function*(){n.instructionElementRef.value&&(n.instructionHidden=!1,yield n.toggleInstructionFocus(!0),n.instructionElementRef.value.style.pointerEvents="auto",n.inputElementRef.value?.blur())})()}toggleInstructionFocus(n){var e=this;return(0,Ge.Z)(function*(){e.instructionElementRef.value&&(yield e.instructionElementRef.value.animate([{opacity:n?0:1},{opacity:n?1:0}],{duration:100,easing:"ease",fill:"forwards"}).finished)})()}onBoxClick(){!this.receiverAddress&&!this.instructionHidden&&this.focusInput()}onBlur(){!this.receiverAddress&&this.instructionHidden&&this.focusInstruction()}checkHidden(){this.instructionHidden&&this.focusInput()}onPasteClick(){return(0,Ge.Z)(function*(){const n=yield navigator.clipboard.readText();ue.Si.setReceiverAddress(n)})()}onInputChange(n){const e=n.target;e.value&&!this.instructionHidden&&this.focusInput(),ue.Si.setReceiverAddress(e.value)}};Gh.styles=HJe,tI([(0,bt.Cb)()],Gh.prototype,"receiverAddress",void 0),tI([(0,bt.SB)()],Gh.prototype,"instructionHidden",void 0),Gh=tI([(0,Xt.customElement)("w3m-input-address")],Gh);const VJe=Ke.iv`
  :host {
    display: flex;
    width: 100%;
    flex-direction: column;
    gap: var(--wui-border-radius-1xs);
    border-radius: var(--wui-border-radius-s);
    background: var(--wui-gray-glass-002);
    padding: var(--wui-spacing-s) var(--wui-spacing-1xs) var(--wui-spacing-1xs)
      var(--wui-spacing-1xs);
  }

  wui-text {
    padding: 0 var(--wui-spacing-1xs);
  }

  wui-flex {
    margin-top: var(--wui-spacing-1xs);
  }

  .network {
    cursor: pointer;
    transition: background-color var(--wui-ease-out-power-1) var(--wui-duration-lg);
    will-change: background-color;
  }

  .network:focus-visible {
    border: 1px solid var(--wui-color-accent-100);
    background-color: var(--wui-gray-glass-005);
    -webkit-box-shadow: 0px 0px 0px 4px var(--wui-box-shadow-blue);
    -moz-box-shadow: 0px 0px 0px 4px var(--wui-box-shadow-blue);
    box-shadow: 0px 0px 0px 4px var(--wui-box-shadow-blue);
  }

  .network:hover {
    background-color: var(--wui-gray-glass-005);
  }

  .network:active {
    background-color: var(--wui-gray-glass-010);
  }
`;var nI=function(t,n,e,i){var a,r=arguments.length,s=r<3?n:null===i?i=Object.getOwnPropertyDescriptor(n,e):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,n,e,i);else for(var o=t.length-1;o>=0;o--)(a=t[o])&&(s=(r<3?a(s):r>3?a(n,e,s):a(n,e))||s);return r>3&&s&&Object.defineProperty(n,e,s),s};let Zh=class extends Ke.oi{render(){return Ke.dy` <wui-text variant="small-400" color="fg-200">Details</wui-text>
      <wui-flex flexDirection="column" gap="xxs">
        <wui-list-content textTitle="Network cost" textValue="$3.20"></wui-list-content>
        <wui-list-content
          textTitle="Address"
          textValue=${Xt.UiHelperUtil.getTruncateString({string:this.receiverAddress??"",charsStart:4,charsEnd:4,truncate:"middle"})}
        >
        </wui-list-content>
        ${this.networkTemplate()}
      </wui-flex>`}networkTemplate(){return this.caipNetwork?.name?Ke.dy` <wui-list-content
        @click=${()=>this.onNetworkClick(this.caipNetwork)}
        class="network"
        textTitle="Network"
        imageSrc=${jn(ue.fz.getNetworkImage(this.caipNetwork))}
      query BunniTokensQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        bunniTokens (
          skip: $skip,
          first: $first
        ) {
          id
          count
          creationTimestamp
          decimals
          name
          symbol
          totalSupply
          liquidityDensityFunction
          ldfParams
          hookParams
          twapSecondsAgo
          rawBalance0
          rawBalance1
          reserve0
          reserve1
          vault0 {
            id
          }
          vault1 {
            id
          }
        }
      }
    `;return yield i.query(r,e)})()}gaugesQuery(e){var i=this;return(0,Ge.Z)(function*(){const r=go`
      query GaugesQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        gauges (
          skip: $skip,
          first: $first
        ) {
          address
          bunniToken
          chain
          tokenlessProduction
          totalSupply
          workingSupply
          bribes (
            where: { 
              deadline: ${i.time.nextEpoch}
            }
          ) {
            amount
            maxTokensPerVote
            token {
              id
              decimals
              name
              price
              symbol
            }
          }
          quests (
            where: {
              periodEnd_gte: ${i.time.nextEpoch}
            }
          ) {
            voteType
            questPeriods (
              where: {
                periodStart: ${i.time.currentEpoch}
              }
            ) {
              rewardAmountPerPeriod
              minRewardPerVote
              maxRewardPerVote
              minObjectiveVotes
              maxObjectiveVotes
            }
            rewardToken {
              id
              decimals
              name
              price
              symbol
            }
          }
          ${null!==F4[e.id]?"exists":""}
          ${null!==F4[e.id]?"relativeWeightCap":""}
        }
      }
    `;return yield i.query(r,e)})()}poolsQuery(e){var i=this;return(0,Ge.Z)(function*(){const r=go`
      query PoolsQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        pools (
          skip: $skip,
          first: $first,
          where: {
            bunniToken_not: null
          }
        ) {
          id
          creationTimestamp
          fee
          tickSpacing
          hooks
          liquidity
          sqrtPriceX96
          tick
          bunniToken {
            id
          }
          currency0 {
            id
          }
          currency1 {
            id
          }
          priceCurrency0
          priceCurrency1
          volumeCurrency0
          volumeCurrency1
          swapFeesCurrency0
          swapFeesCurrency1
          managerFeesCurrency0
          managerFeesCurrency1
          rentCurrency0
          rentCurrency1
          topBid {
            manager
            epoch
            rent
            deposit
          }
          nextBid {
            manager
            epoch
            rent
            deposit
          }
        }
      }
    `;return yield i.query(r,e)})()}poolTransctionQuery(e,i,r,s){var a=this;return(0,Ge.Z)(function*(){const o=go`
      query PoolTransactionsQuery (
        $skip: Int = ${i},
        $first: Int = ${r},
      ) {
        pool (id: "${e.id.toLowerCase()}") {
          transactions (
            skip: $skip,
            first: $first,
            orderBy: timestamp,
            orderDirection: desc
          ) {
            id
            timestamp
            deposits {
              sender
              amount0
              amount1
              amountUSD
            }
            withdraws {
              sender
              amount0
              amount1
              amountUSD
            }
            swaps {
              sender
              amount0
              amount1
              amountUSD
            }
          }
        }
      }
    `;return yield a.query(o,s)})()}tokenTransctionQuery(e,i,r,s){var a=this;return(0,Ge.Z)(function*(){const o=go`
      query TokenTransactionsQuery (
        $skip: Int = ${i},
        $first: Int = ${r},
      ) {
        currency (id: "${e.address.toLowerCase()}") {
          transactions (
            skip: $skip,
            first: $first,
            orderBy: timestamp,
            orderDirection: desc
          ) {
            id
            timestamp
            deposits {
              pool {
                id
              }
              currency0 {
                id
              }
              currency1 {
                id
              }
              sender
              amount0
              amount1
              amountUSD
            }
            withdraws {
              pool {
                id
              }
              currency0 {
                id
              }
              currency1 {
                id
              }
              sender
              amount0
              amount1
              amountUSD
            }
            swaps {
              pool {
                id
              }
              currency0 {
                id
              }
              currency1 {
                id
              }
              sender
              amount0
              amount1
              amountUSD
            }
          }
        }
      }
    `;return yield a.query(o,s)})()}tokensQuery(e){var i=this;return(0,Ge.Z)(function*(){const r=go`
      query TokensQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        currencies (
          skip: $skip,
          first: $first,
          where: {
            bunniTokenCount_gt: 0
          }
        ) {
          id
          creationTimestamp
          decimals
          name
          price
          symbol
          rawBalance
          volume
        }
      }
    `;return yield i.query(r,e)})()}userQuery(e,i){var r=this;return(0,Ge.Z)(function*(){const s=go`{
      user (id: "${e.toLowerCase()}") {
        bunniTokenPositions (
          first: 1000,
          where: { 
            or: [{ balance_gt: 0 }, { gaugeBalance_gt: 0 }]
          }
        ) {
          balance
          gaugeBalance
          workingBalance
          claimedRewards
          currency0CostBasisPerShare
          currency1CostBasisPerShare
          claimedRewardsPerShare
          bunniToken {
            id
          }
        }
        ${""}
        ${""}
      }
    }`;return yield r.query(s,i)})()}vaultsQuery(e){var i=this;return(0,Ge.Z)(function*(){const r=go`
      query VaultsQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        vaults (
          skip: $skip,
          first: $first
        ) {
          id
          asset {
            id
          }
          decimals
          name
          symbol
          reserve
        }
      }
    `;return yield i.query(r,e)})()}blockBunniTokensQuery(e,i){var r=this;return(0,Ge.Z)(function*(){const s=go`
      query BlockBunniTokensQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        bunniTokens (
          skip: $skip,
          first: $first,
          block: {
            number: ${e}
          }
        ) {
          id
          totalSupply
          rawBalance0
          rawBalance1
          reserve0
          reserve1
        }
      }
    `;return yield r.query(s,i)})()}blockTokensQuery(e,i){var r=this;return(0,Ge.Z)(function*(){const s=go`
      query BlockTokensQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        currencies (
          skip: $skip,
          first: $first,
          block: {
            number: ${e}
          },
          where: {
            bunniTokenCount_gt: 0
          }
        ) {
          id
          price
          rawBalance
          volume
        }
      }
    `;return yield r.query(s,i)})()}blockPoolsQuery(e,i){var r=this;return(0,Ge.Z)(function*(){const s=go`
      query BlockPoolsQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        pools (
          skip: $skip,
          first: $first,
          block: {
            number: ${e}
          },
          where: {
            bunniToken_not: null
          }
        ) {
          id
          priceCurrency0
          priceCurrency1
          volumeCurrency0
          volumeCurrency1
          swapFeesCurrency0
          swapFeesCurrency1
          managerFeesCurrency0
          managerFeesCurrency1
          rentCurrency0
          rentCurrency1
          topBid {
            manager
            epoch
            rent
            deposit
          }
          nextBid {
            manager
            epoch
            rent
            deposit
          }
        }
      }
    `;return yield r.query(s,i)})()}blockVaultsQuery(e,i){var r=this;return(0,Ge.Z)(function*(){const s=go`
      query BlockVaultsQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        vaults (
          skip: $skip,
          first: $first,
          block: {
            number: ${e}
          },
        ) {
          id
          reserve
        }
      }
    `;return yield r.query(s,i)})()}poolSnapshotsQuery(e,i,r,s,a,o){var c=this;return(0,Ge.Z)(function*(){const l=`poolMinuteSnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        pool: "${e.id.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.day}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      volumeUSD\n      swapFeesUSD\n      open\n      high\n      low\n      close\n    }`,u=`poolHourSnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        pool: "${e.id.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.month}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      volumeUSD\n      swapFeesUSD\n      open\n      high\n      low\n      close\n    }`,d=`poolDaySnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        pool: "${e.id.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.year}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      volumeUSD\n      swapFeesUSD\n      open\n      high\n      low\n      close\n    }`,h=`poolWeekSnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        pool: "${e.id.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.year}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      volumeUSD\n      swapFeesUSD\n      open\n      high\n      low\n      close\n    }`,y=go`
      query PoolSnapshotsQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        ${i?l:""}
        ${r?u:""}
        ${s?d:""}
        ${a?h:""}
      }
    `;return yield c.query(y,o)})()}tokenSnapshotsQuery(e,i,r,s,a,o){var c=this;return(0,Ge.Z)(function*(){const l=`currencyMinuteSnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        currency: "${e.address.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.day}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      totalValueLockedUSD\n      volumeUSD\n      open\n      high\n      low\n      close\n    }`,u=`currencyHourSnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        currency: "${e.address.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.month}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      totalValueLockedUSD\n      volumeUSD\n      open\n      high\n      low\n      close\n    }`,d=`currencyDaySnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        currency: "${e.address.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.year}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      totalValueLockedUSD\n      volumeUSD\n      open\n      high\n      low\n      close\n    }`,h=`currencyWeekSnapshots(\n      skip: $skip,\n      first: $first,\n      orderBy: index,\n      orderDirection: desc,\n      where: {\n        currency: "${e.address.toLowerCase()}",\n        periodStart_gte: ${c.time.now-c.time.year}\n      }\n    ) {\n      index\n      periodStart\n      periodEnd\n      totalValueLockedUSD\n      volumeUSD\n      open\n      high\n      low\n      close\n    }`,y=go`
      query TokenSnapshotsQuery (
        $skip: Int = 0,
        $first: Int = 1000
      ) {
        ${i?l:""}
        ${r?u:""}
        ${s?d:""}
        ${a?h:""}
      }
    `;return yield c.query(y,o)})()}blocksQuery(e){var i=this;return(0,Ge.Z)(function*(){const r=go`
      query BlocksQuery {
        hour: blocks (
          first: 1,
          orderBy: number,
          orderDirection: asc,
          where: {
            timestamp_gte: ${i.time.now-i.time.hour}
            timestamp_lt: ${i.time.now-i.time.hour+i.time.minute}
          }
        ) {
          number
        }
        day: blocks (
          first: 1,
          orderBy: number,
          orderDirection: asc,
          where: {
            timestamp_gte: ${i.time.now-i.time.day}
            timestamp_lt: ${i.time.now-i.time.day+i.time.minute}
          }
        ) {
          number
        }
        week: blocks (
          first: 1,
          orderBy: number,
          orderDirection: asc,
          where: {
            timestamp_gte: ${i.time.now-i.time.week}
            timestamp_lt: ${i.time.now-i.time.week+i.time.minute}
          }
        ) {
          number
        }
        month: blocks (
          first: 1,
          orderBy: number,
          orderDirection: asc,
          where: {
            timestamp_gte: ${i.time.now-i.time.month}
            timestamp_lt: ${i.time.now-i.time.month+i.time.minute}
          }
        ) {
          number
        }
        year: blocks (
          first: 1,
          orderBy: number,
          orderDirection: asc,
          where: {
            timestamp_gte: ${i.time.now-i.time.year}
            timestamp_lt: ${i.time.now-i.time.year+i.time.minute}
          }
        ) {
          number
        }
      }
  :host {
    z-index: var(--w3m-z-index);
    display: block;
    backface-visibility: hidden;
    will-change: opacity;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    pointer-events: none;
    opacity: 0;
    background-color: var(--wui-cover);
  }

  @keyframes zoom-in {
    0% {
      transform: scale(0.95) translateY(0);
    }
    100% {
      transform: scale(1) translateY(0);
    }
  }

  @keyframes slide-in {
    0% {
      transform: scale(1) translateY(50px);
    }
    100% {
      transform: scale(1) translateY(0);
    }
  }

  wui-card {
    max-width: 360px;
    width: 100%;
    position: relative;
    animation-duration: 0.2s;
    animation-name: zoom-in;
    animation-fill-mode: backwards;
    animation-timing-function: var(--wui-ease-out-power-2);
    outline: none;
  }

  wui-flex {
    overflow-x: hidden;
    overflow-y: auto;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
  }

  @media (max-height: 700px) and (min-width: 431px) {
    wui-flex {
      align-items: flex-start;
    }

    wui-card {
      margin: var(--wui-spacing-xxl) 0px;
    }
  }

  @media (max-width: 430px) {
    wui-flex {
      align-items: flex-end;
    }

    wui-card {
      max-width: 100%;
      border-bottom-left-radius: 0;
      border-bottom-right-radius: 0;
      border-bottom: none;
      animation-name: slide-in;
    }
  }
`;var p=function(E,k,F,J){var oe,R=arguments.length,ee=R<3?k:null===J?J=Object.getOwnPropertyDescriptor(k,F):J;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)ee=Reflect.decorate(E,k,F,J);else for(var re=E.length-1;re>=0;re--)(oe=E[re])&&(ee=(R<3?oe(ee):R>3?oe(k,F,ee):oe(k,F))||ee);return R>3&&ee&&Object.defineProperty(k,F,ee),ee};const x="scroll-lock";let T=class extends b.oi{constructor(){super(),this.unsubscribe=[],this.abortController=void 0,this.open=ce.IN.state.open,this.caipAddress=ce.AccountController.state.caipAddress,this.isSiweEnabled=ce.OptionsController.state.isSiweEnabled,this.initializeTheming(),ce.ApiController.prefetch(),this.unsubscribe.push(ce.IN.subscribeKey("open",k=>k?this.onOpen():this.onClose()),ce.AccountController.subscribe(k=>this.onNewAccountState(k))),ce.Xs.sendEvent({type:"track",event:"MODAL_LOADED"})}disconnectedCallback(){this.unsubscribe.forEach(k=>k()),this.onRemoveKeyboardListener()}render(){return this.open?b.dy`
          <wui-flex @click=${this.onOverlayClick.bind(this)}>
            <wui-card role="alertdialog" aria-modal="true" tabindex="0">
              <w3m-header></w3m-header>
              <w3m-router></w3m-router>
              <w3m-snackbar></w3m-snackbar>
            </wui-card>
          </wui-flex>
        `:null}onOverlayClick(k){var F=this;return(0,Y.Z)(function*(){k.target===k.currentTarget&&(yield F.handleClose())})()}handleClose(){var k=this;return(0,Y.Z)(function*(){if(k.isSiweEnabled){const{SIWEController:F}=yield $.e(632).then($.bind($,4632));"success"!==F.state.status&&(yield ce.ConnectionController.disconnect())}ce.IN.close()})()}initializeTheming(){const{themeVariables:k,themeMode:F}=ce.ThemeController.state,J=z.UiHelperUtil.getColorTheme(F);(0,z.initializeTheming)(k,J)}onClose(){var k=this;return(0,Y.Z)(function*(){k.onScrollUnlock(),yield k.animate([{opacity:1},{opacity:0}],{duration:200,easing:"ease",fill:"forwards"}).finished,ce.SnackController.hide(),k.open=!1,k.onRemoveKeyboardListener()})()}onOpen(){var k=this;return(0,Y.Z)(function*(){k.onScrollLock(),k.open=!0,yield k.animate([{opacity:0},{opacity:1}],{duration:200,easing:"ease",fill:"forwards"}).finished,k.onAddKeyboardListener()})()}onScrollLock(){const k=document.createElement("style");k.dataset.w3m=x,k.textContent="\n      html, body {\n        touch-action: none;\n        overflow: hidden;\n        overscroll-behavior: contain;\n      }\n      w3m-modal {\n        pointer-events: auto;\n      }\n    ",document.head.appendChild(k)}onScrollUnlock(){const k=document.head.querySelector(`style[data-w3m="${x}"]`);k&&k.remove()}onAddKeyboardListener(){this.abortController=new AbortController;const k=this.shadowRoot?.querySelector("wui-card");k?.focus(),window.addEventListener("keydown",F=>{if("Escape"===F.key)this.handleClose();else if("Tab"===F.key){const{tagName:J}=F.target;J&&!J.includes("W3M-")&&!J.includes("WUI-")&&k?.focus()}},this.abortController)}onRemoveKeyboardListener(){this.abortController?.abort(),this.abortController=void 0}onNewAccountState(k){var F=this;return(0,Y.Z)(function*(){const{isConnected:J,caipAddress:R}=k;if(F.isSiweEnabled){const{SIWEController:ee}=yield $.e(632).then($.bind($,4632));J&&!F.caipAddress&&(F.caipAddress=R),J&&R&&F.caipAddress!==R&&(yield ee.signOut(),F.onSiweNavigation(),F.caipAddress=R);try{const oe=yield ee.getSession();oe&&!J?yield ee.signOut():J&&!oe&&F.onSiweNavigation()}catch{J&&F.onSiweNavigation()}}})()}onSiweNavigation(){this.open?ce.RouterController.push("ConnectingSiwe"):ce.IN.open({view:"ConnectingSiwe"})}};T.styles=g,p([(0,w.SB)()],T.prototype,"open",void 0),p([(0,w.SB)()],T.prototype,"caipAddress",void 0),p([(0,w.SB)()],T.prototype,"isSiweEnabled",void 0),T=p([(0,z.customElement)("w3m-modal")],T)},5174:(at,He,$)=>{"use strict";$.d(He,{fl:()=>be,iv:()=>x,Ts:()=>Me,Qu:()=>he});var Y=$(5861);const ce=globalThis,z=ce.ShadowRoot&&(void 0===ce.ShadyCSS||ce.ShadyCSS.nativeShadow)&&"adoptedStyleSheets"in Document.prototype&&"replace"in CSSStyleSheet.prototype,b=Symbol(),w=new WeakMap;class g{constructor(ge,ve,K){if(this._$cssResult$=!0,K!==b)throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");this.cssText=ge,this.t=ve}get styleSheet(){let ge=this.o;const ve=this.t;if(z&&void 0===ge){const K=void 0!==ve&&1===ve.length;K&&(ge=w.get(ve)),void 0===ge&&((this.o=ge=new CSSStyleSheet).replaceSync(this.cssText),K&&w.set(ve,ge))}return ge}toString(){return this.cssText}}const x=(_e,...ge)=>{const ve=1===_e.length?_e[0]:ge.reduce((K,H,C)=>K+(j=>{if(!0===j._$cssResult$)return j.cssText;if("number"==typeof j)return j;throw Error("Value passed to 'css' function must be a 'css' function result: "+j+". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.")})(H)+_e[C+1],_e[0]);return new g(ve,_e,b)},E=z?_e=>_e:_e=>_e instanceof CSSStyleSheet?(ge=>{let ve="";for(const K of ge.cssRules)ve+=K.cssText;return(_e=>new g("string"==typeof _e?_e:_e+"",void 0,b))(ve)})(_e):_e,{is:k,defineProperty:F,getOwnPropertyDescriptor:J,getOwnPropertyNames:R,getOwnPropertySymbols:ee,getPrototypeOf:oe}=Object,re=globalThis,Pe=re.trustedTypes,Re=Pe?Pe.emptyScript:"",De=re.reactiveElementPolyfillSupport,Ae=(_e,ge)=>_e,Me={toAttribute(_e,ge){switch(ge){case Boolean:_e=_e?Re:null;break;case Object:case Array:_e=null==_e?_e:JSON.stringify(_e)}return _e},fromAttribute(_e,ge){let ve=_e;switch(ge){case Boolean:ve=null!==_e;break;case Number:ve=null===_e?null:Number(_e);break;case Object:case Array:try{ve=JSON.parse(_e)}catch{ve=null}}return ve}},he=(_e,ge)=>!k(_e,ge),me={attribute:!0,type:String,converter:Me,reflect:!1,hasChanged:he};Symbol.metadata??=Symbol("metadata"),re.litPropertyMetadata??=new WeakMap;class be extends HTMLElement{static addInitializer(ge){this._$Ei(),(this.l??=[]).push(ge)}static get observedAttributes(){return this.finalize(),this._$Eh&&[...this._$Eh.keys()]}static createProperty(ge,ve=me){if(ve.state&&(ve.attribute=!1),this._$Ei(),this.elementProperties.set(ge,ve),!ve.noAccessor){const K=Symbol(),H=this.getPropertyDescriptor(ge,K,ve);void 0!==H&&F(this.prototype,ge,H)}}static getPropertyDescriptor(ge,ve,K){const{get:H,set:C}=J(this.prototype,ge)??{get(){return this[ve]},set(j){this[ve]=j}};return{get(){return H?.call(this)},set(j){const te=H?.call(this);C.call(this,j),this.requestUpdate(ge,te,K)},configurable:!0,enumerable:!0}}static getPropertyOptions(ge){return this.elementProperties.get(ge)??me}static _$Ei(){if(this.hasOwnProperty(Ae("elementProperties")))return;const ge=oe(this);ge.finalize(),void 0!==ge.l&&(this.l=[...ge.l]),this.elementProperties=new Map(ge.elementProperties)}static finalize(){if(this.hasOwnProperty(Ae("finalized")))return;if(this.finalized=!0,this._$Ei(),this.hasOwnProperty(Ae("properties"))){const ve=this.properties,K=[...R(ve),...ee(ve)];for(const H of K)this.createProperty(H,ve[H])}const ge=this[Symbol.metadata];if(null!==ge){const ve=litPropertyMetadata.get(ge);if(void 0!==ve)for(const[K,H]of ve)this.elementProperties.set(K,H)}this._$Eh=new Map;for(const[ve,K]of this.elementProperties){const H=this._$Eu(ve,K);void 0!==H&&this._$Eh.set(H,ve)}this.elementStyles=this.finalizeStyles(this.styles)}static finalizeStyles(ge){const ve=[];if(Array.isArray(ge)){const K=new Set(ge.flat(1/0).reverse());for(const H of K)ve.unshift(E(H))}else void 0!==ge&&ve.push(E(ge));return ve}static _$Eu(ge,ve){const K=ve.attribute;return!1===K?void 0:"string"==typeof K?K:"string"==typeof ge?ge.toLowerCase():void 0}constructor(){super(),this._$Ep=void 0,this.isUpdatePending=!1,this.hasUpdated=!1,this._$Em=null,this._$Ev()}_$Ev(){this._$ES=new Promise(ge=>this.enableUpdating=ge),this._$AL=new Map,this._$E_(),this.requestUpdate(),this.constructor.l?.forEach(ge=>ge(this))}addController(ge){(this._$EO??=new Set).add(ge),void 0!==this.renderRoot&&this.isConnected&&ge.hostConnected?.()}removeController(ge){this._$EO?.delete(ge)}_$E_(){const ge=new Map,ve=this.constructor.elementProperties;for(const K of ve.keys())this.hasOwnProperty(K)&&(ge.set(K,this[K]),delete this[K]);ge.size>0&&(this._$Ep=ge)}createRenderRoot(){const ge=this.shadowRoot??this.attachShadow(this.constructor.shadowRootOptions);return((_e,ge)=>{if(z)_e.adoptedStyleSheets=ge.map(ve=>ve instanceof CSSStyleSheet?ve:ve.styleSheet);else for(const ve of ge){const K=document.createElement("style"),H=ce.litNonce;void 0!==H&&K.setAttribute("nonce",H),K.textContent=ve.cssText,_e.appendChild(K)}})(ge,this.constructor.elementStyles),ge}connectedCallback(){this.renderRoot??=this.createRenderRoot(),this.enableUpdating(!0),this._$EO?.forEach(ge=>ge.hostConnected?.())}enableUpdating(ge){}disconnectedCallback(){this._$EO?.forEach(ge=>ge.hostDisconnected?.())}attributeChangedCallback(ge,ve,K){this._$AK(ge,K)}_$EC(ge,ve){const K=this.constructor.elementProperties.get(ge),H=this.constructor._$Eu(ge,K);if(void 0!==H&&!0===K.reflect){const C=(void 0!==K.converter?.toAttribute?K.converter:Me).toAttribute(ve,K.type);this._$Em=ge,null==C?this.removeAttribute(H):this.setAttribute(H,C),this._$Em=null}}_$AK(ge,ve){const K=this.constructor,H=K._$Eh.get(ge);if(void 0!==H&&this._$Em!==H){const C=K.getPropertyOptions(H),j="function"==typeof C.converter?{fromAttribute:C.converter}:void 0!==C.converter?.fromAttribute?C.converter:Me;this._$Em=H,this[H]=j.fromAttribute(ve,C.type),this._$Em=null}}requestUpdate(ge,ve,K){if(void 0!==ge){if(K??=this.constructor.getPropertyOptions(ge),!(K.hasChanged??he)(this[ge],ve))return;this.P(ge,ve,K)}!1===this.isUpdatePending&&(this._$ES=this._$ET())}P(ge,ve,K){this._$AL.has(ge)||this._$AL.set(ge,ve),!0===K.reflect&&this._$Em!==ge&&(this._$Ej??=new Set).add(ge)}_$ET(){var ge=this;return(0,Y.Z)(function*(){ge.isUpdatePending=!0;try{yield ge._$ES}catch(K){Promise.reject(K)}const ve=ge.scheduleUpdate();return null!=ve&&(yield ve),!ge.isUpdatePending})()}scheduleUpdate(){return this.performUpdate()}performUpdate(){if(!this.isUpdatePending)return;if(!this.hasUpdated){if(this.renderRoot??=this.createRenderRoot(),this._$Ep){for(const[H,C]of this._$Ep)this[H]=C;this._$Ep=void 0}const K=this.constructor.elementProperties;if(K.size>0)for(const[H,C]of K)!0!==C.wrapped||this._$AL.has(H)||void 0===this[H]||this.P(H,this[H],C)}let ge=!1;const ve=this._$AL;try{ge=this.shouldUpdate(ve),ge?(this.willUpdate(ve),this._$EO?.forEach(K=>K.hostUpdate?.()),this.update(ve)):this._$EU()}catch(K){throw ge=!1,this._$EU(),K}ge&&this._$AE(ve)}willUpdate(ge){}_$AE(ge){this._$EO?.forEach(ve=>ve.hostUpdated?.()),this.hasUpdated||(this.hasUpdated=!0,this.firstUpdated(ge)),this.updated(ge)}_$EU(){this._$AL=new Map,this.isUpdatePending=!1}get updateComplete(){return this.getUpdateComplete()}getUpdateComplete(){return this._$ES}shouldUpdate(ge){return!0}update(ge){this._$Ej&&=this._$Ej.forEach(ve=>this._$EC(ve,this[ve])),this._$EU()}updated(ge){}firstUpdated(ge){}}be.elementStyles=[],be.shadowRootOptions={mode:"open"},be[Ae("elementProperties")]=new Map,be[Ae("finalized")]=new Map,De?.({ReactiveElement:be}),(re.reactiveElementVersions??=[]).push("2.0.4")},9810:(at,He,$)=>{"use strict";$.d(He,{Jb:()=>me,Ld:()=>be,_$LH:()=>S,dy:()=>Me,sY:()=>Ue});const Y=globalThis,ce=Y.trustedTypes,z=ce?ce.createPolicy("lit-html",{createHTML:Ze=>Ze}):void 0,b="$lit$",w=`lit$${Math.random().toFixed(9).slice(2)}$`,g="?"+w,p=`<${g}>`,x=document,T=()=>x.createComment(""),E=Ze=>null===Ze||"object"!=typeof Ze&&"function"!=typeof Ze,k=Array.isArray,F=Ze=>k(Ze)||"function"==typeof Ze?.[Symbol.iterator],J="[ \t\n\f\r]",R=/<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g,ee=/-->/g,oe=/>/g,re=RegExp(`>|${J}(?:([^\\s"'>=/]+)(${J}*=${J}*(?:[^ \t\n\f\r"'\`<>=]|("|')|))|$)`,"g"),Pe=/'/g,Re=/"/g,De=/^(?:script|style|textarea|title)$/i,Ae=Ze=>(Q,...Le)=>({_$litType$:Ze,strings:Q,values:Le}),Me=Ae(1),me=(Ae(2),Symbol.for("lit-noChange")),be=Symbol.for("lit-nothing"),_e=new WeakMap,ge=x.createTreeWalker(x,129);function ve(Ze,Q){if(!Array.isArray(Ze)||!Ze.hasOwnProperty("raw"))throw Error("invalid template strings array");return void 0!==z?z.createHTML(Q):Q}const K=(Ze,Q)=>{const Le=Ze.length-1,ze=[];let pe,de=2===Q?"<svg>":"",ke=R;for(let Xe=0;Xe<Le;Xe++){const We=Ze[Xe];let ct,st,Je=-1,ft=0;for(;ft<We.length&&(ke.lastIndex=ft,st=ke.exec(We),null!==st);)ft=ke.lastIndex,ke===R?"!--"===st[1]?ke=ee:void 0!==st[1]?ke=oe:void 0!==st[2]?(De.test(st[2])&&(pe=RegExp("</"+st[2],"g")),ke=re):void 0!==st[3]&&(ke=re):ke===re?">"===st[0]?(ke=pe??R,Je=-1):void 0===st[1]?Je=-2:(Je=ke.lastIndex-st[2].length,ct=st[1],ke=void 0===st[3]?re:'"'===st[3]?Re:Pe):ke===Re||ke===Pe?ke=re:ke===ee||ke===oe?ke=R:(ke=re,pe=void 0);const ot=ke===re&&Ze[Xe+1].startsWith("/>")?" ":"";de+=ke===R?We+p:Je>=0?(ze.push(ct),We.slice(0,Je)+b+We.slice(Je)+w+ot):We+w+(-2===Je?Xe:ot)}return[ve(Ze,de+(Ze[Le]||"<?>")+(2===Q?"</svg>":"")),ze]};class H{constructor({strings:Q,_$litType$:Le},ze){let pe;this.parts=[];let de=0,ke=0;const Xe=Q.length-1,We=this.parts,[ct,st]=K(Q,Le);if(this.el=H.createElement(ct,ze),ge.currentNode=this.el.content,2===Le){const Je=this.el.content.firstChild;Je.replaceWith(...Je.childNodes)}for(;null!==(pe=ge.nextNode())&&We.length<Xe;){if(1===pe.nodeType){if(pe.hasAttributes())for(const Je of pe.getAttributeNames())if(Je.endsWith(b)){const ft=st[ke++],ot=pe.getAttribute(Je).split(w),lt=/([.?@])?(.*)/.exec(ft);We.push({type:1,index:de,name:lt[2],strings:ot,ctor:"."===lt[1]?ae:"?"===lt[1]?ne:"@"===lt[1]?se:W}),pe.removeAttribute(Je)}else Je.startsWith(w)&&(We.push({type:6,index:de}),pe.removeAttribute(Je));if(De.test(pe.tagName)){const Je=pe.textContent.split(w),ft=Je.length-1;if(ft>0){pe.textContent=ce?ce.emptyScript:"";for(let ot=0;ot<ft;ot++)pe.append(Je[ot],T()),ge.nextNode(),We.push({type:2,index:++de});pe.append(Je[ft],T())}}}else if(8===pe.nodeType)if(pe.data===g)We.push({type:2,index:de});else{let Je=-1;for(;-1!==(Je=pe.data.indexOf(w,Je+1));)We.push({type:7,index:de}),Je+=w.length-1}de++}}static createElement(Q,Le){const ze=x.createElement("template");return ze.innerHTML=Q,ze}}function C(Ze,Q,Le=Ze,ze){if(Q===me)return Q;let pe=void 0!==ze?Le._$Co?.[ze]:Le._$Cl;const de=E(Q)?void 0:Q._$litDirective$;return pe?.constructor!==de&&(pe?._$AO?.(!1),void 0===de?pe=void 0:(pe=new de(Ze),pe._$AT(Ze,Le,ze)),void 0!==ze?(Le._$Co??=[])[ze]=pe:Le._$Cl=pe),void 0!==pe&&(Q=C(Ze,pe._$AS(Ze,Q.values),pe,ze)),Q}class j{constructor(Q,Le){this._$AV=[],this._$AN=void 0,this._$AD=Q,this._$AM=Le}get parentNode(){return this._$AM.parentNode}get _$AU(){return this._$AM._$AU}u(Q){const{el:{content:Le},parts:ze}=this._$AD,pe=(Q?.creationScope??x).importNode(Le,!0);ge.currentNode=pe;let de=ge.nextNode(),ke=0,Xe=0,We=ze[0];for(;void 0!==We;){if(ke===We.index){let ct;2===We.type?ct=new te(de,de.nextSibling,this,Q):1===We.type?ct=new We.ctor(de,We.name,We.strings,this,Q):6===We.type&&(ct=new U(de,this,Q)),this._$AV.push(ct),We=ze[++Xe]}ke!==We?.index&&(de=ge.nextNode(),ke++)}return ge.currentNode=x,pe}p(Q){let Le=0;for(const ze of this._$AV)void 0!==ze&&(void 0!==ze.strings?(ze._$AI(Q,ze,Le),Le+=ze.strings.length-2):ze._$AI(Q[Le])),Le++}}class te{get _$AU(){return this._$AM?._$AU??this._$Cv}constructor(Q,Le,ze,pe){this.type=2,this._$AH=be,this._$AN=void 0,this._$AA=Q,this._$AB=Le,this._$AM=ze,this.options=pe,this._$Cv=pe?.isConnected??!0}get parentNode(){let Q=this._$AA.parentNode;const Le=this._$AM;return void 0!==Le&&11===Q?.nodeType&&(Q=Le.parentNode),Q}get startNode(){return this._$AA}get endNode(){return this._$AB}_$AI(Q,Le=this){Q=C(this,Q,Le),E(Q)?Q===be||null==Q||""===Q?(this._$AH!==be&&this._$AR(),this._$AH=be):Q!==this._$AH&&Q!==me&&this._(Q):void 0!==Q._$litType$?this.$(Q):void 0!==Q.nodeType?this.T(Q):F(Q)?this.k(Q):this._(Q)}S(Q){return this._$AA.parentNode.insertBefore(Q,this._$AB)}T(Q){this._$AH!==Q&&(this._$AR(),this._$AH=this.S(Q))}_(Q){this._$AH!==be&&E(this._$AH)?this._$AA.nextSibling.data=Q:this.T(x.createTextNode(Q)),this._$AH=Q}$(Q){const{values:Le,_$litType$:ze}=Q,pe="number"==typeof ze?this._$AC(Q):(void 0===ze.el&&(ze.el=H.createElement(ve(ze.h,ze.h[0]),this.options)),ze);if(this._$AH?._$AD===pe)this._$AH.p(Le);else{const de=new j(pe,this),ke=de.u(this.options);de.p(Le),this.T(ke),this._$AH=de}}_$AC(Q){let Le=_e.get(Q.strings);return void 0===Le&&_e.set(Q.strings,Le=new H(Q)),Le}k(Q){k(this._$AH)||(this._$AH=[],this._$AR());const Le=this._$AH;let ze,pe=0;for(const de of Q)pe===Le.length?Le.push(ze=new te(this.S(T()),this.S(T()),this,this.options)):ze=Le[pe],ze._$AI(de),pe++;pe<Le.length&&(this._$AR(ze&&ze._$AB.nextSibling,pe),Le.length=pe)}_$AR(Q=this._$AA.nextSibling,Le){for(this._$AP?.(!1,!0,Le);Q&&Q!==this._$AB;){const ze=Q.nextSibling;Q.remove(),Q=ze}}setConnected(Q){void 0===this._$AM&&(this._$Cv=Q,this._$AP?.(Q))}}class W{get tagName(){return this.element.tagName}get _$AU(){return this._$AM._$AU}constructor(Q,Le,ze,pe,de){this.type=1,this._$AH=be,this._$AN=void 0,this.element=Q,this.name=Le,this._$AM=pe,this.options=de,ze.length>2||""!==ze[0]||""!==ze[1]?(this._$AH=Array(ze.length-1).fill(new String),this.strings=ze):this._$AH=be}_$AI(Q,Le=this,ze,pe){const de=this.strings;let ke=!1;if(void 0===de)Q=C(this,Q,Le,0),ke=!E(Q)||Q!==this._$AH&&Q!==me,ke&&(this._$AH=Q);else{const Xe=Q;let We,ct;for(Q=de[0],We=0;We<de.length-1;We++)ct=C(this,Xe[ze+We],Le,We),ct===me&&(ct=this._$AH[We]),ke||=!E(ct)||ct!==this._$AH[We],ct===be?Q=be:Q!==be&&(Q+=(ct??"")+de[We+1]),this._$AH[We]=ct}ke&&!pe&&this.j(Q)}j(Q){Q===be?this.element.removeAttribute(this.name):this.element.setAttribute(this.name,Q??"")}}class ae extends W{constructor(){super(...arguments),this.type=3}j(Q){this.element[this.name]=Q===be?void 0:Q}}class ne extends W{constructor(){super(...arguments),this.type=4}j(Q){this.element.toggleAttribute(this.name,!!Q&&Q!==be)}}class se extends W{constructor(Q,Le,ze,pe,de){super(Q,Le,ze,pe,de),this.type=5}_$AI(Q,Le=this){if((Q=C(this,Q,Le,0)??be)===me)return;const ze=this._$AH,pe=Q===be&&ze!==be||Q.capture!==ze.capture||Q.once!==ze.once||Q.passive!==ze.passive,de=Q!==be&&(ze===be||pe);pe&&this.element.removeEventListener(this.name,this,ze),de&&this.element.addEventListener(this.name,this,Q),this._$AH=Q}handleEvent(Q){"function"==typeof this._$AH?this._$AH.call(this.options?.host??this.element,Q):this._$AH.handleEvent(Q)}}class U{constructor(Q,Le,ze){this.element=Q,this.type=6,this._$AN=void 0,this._$AM=Le,this.options=ze}get _$AU(){return this._$AM._$AU}_$AI(Q){C(this,Q)}}const S={P:b,A:w,C:g,M:1,L:K,R:j,D:F,V:C,I:te,H:W,N:ne,U:se,B:ae,F:U},le=Y.litHtmlPolyfillSupport;le?.(H,te),(Y.litHtmlVersions??=[]).push("3.1.3");const Ue=(Ze,Q,Le)=>{const ze=Le?.renderBefore??Q;let pe=ze._$litPart$;if(void 0===pe){const de=Le?.renderBefore??null;ze._$litPart$=pe=new te(Q.insertBefore(T(),de),de,void 0,Le??{})}return pe._$AI(Ze),pe}},5937:(at,He,$)=>{"use strict";$.d(He,{Cb:()=>b,SB:()=>w});var Y=$(5174);const ce={attribute:!0,type:String,converter:Y.Ts,reflect:!1,hasChanged:Y.Qu},z=(g=ce,p,x)=>{const{kind:T,metadata:E}=x;let k=globalThis.litPropertyMetadata.get(E);if(void 0===k&&globalThis.litPropertyMetadata.set(E,k=new Map),k.set(x.name,g),"accessor"===T){const{name:F}=x;return{set(J){const R=p.get.call(this);p.set.call(this,J),this.requestUpdate(F,R,g)},init(J){return void 0!==J&&this.P(F,void 0,g),J}}}if("setter"===T){const{name:F}=x;return function(J){const R=this[F];p.call(this,J),this.requestUpdate(F,R,g)}}throw Error("Unsupported decorator location: "+T)};function b(g){return(p,x)=>"object"==typeof x?z(g,p,x):((T,E,k)=>{const F=E.hasOwnProperty(k);return E.constructor.createProperty(k,F?{...T,wrapped:!0}:T),F?Object.getOwnPropertyDescriptor(E,k):void 0})(g,p,x)}function w(g){return b({...g,state:!0,attribute:!1})}},6494:(at,He,$)=>{"use strict";$.d(He,{oi:()=>z,iv:()=>Y.iv,dy:()=>ce.dy});var Y=$(5174),ce=$(9810);class z extends Y.fl{constructor(){super(...arguments),this.renderOptions={host:this},this._$Do=void 0}createRenderRoot(){const p=super.createRenderRoot();return this.renderOptions.renderBefore??=p.firstChild,p}update(p){const x=this.render();this.hasUpdated||(this.renderOptions.isConnected=this.isConnected),super.update(p),this._$Do=(0,ce.sY)(x,this.renderRoot,this.renderOptions)}connectedCallback(){super.connectedCallback(),this._$Do?.setConnected(!0)}disconnectedCallback(){super.disconnectedCallback(),this._$Do?.setConnected(!1)}render(){return ce.Jb}}z._$litElement$=!0,z.finalized=!0,globalThis.litElementHydrateSupport?.({LitElement:z});const b=globalThis.litElementPolyfillSupport;b?.({LitElement:z}),(globalThis.litElementVersions??=[]).push("4.0.5")},7989:(at,He,$)=>{"use strict";$.r(He),$.d(He,{TransactionUtil:()=>M3,UiHelperUtil:()=>ir,WuiAccountButton:()=>ka,WuiAllWalletsImage:()=>is,WuiAvatar:()=>Qc,WuiBalance:()=>ac,WuiBanner:()=>T3,WuiButton:()=>Sa,WuiCard:()=>Vn,WuiCardSelect:()=>da,WuiCardSelectLoader:()=>G0,WuiChip:()=>fa,WuiChipButton:()=>Z1,WuiCompatibleNetwork:()=>x3,WuiConnectButton:()=>tl,WuiCtaButton:()=>u1,WuiDetailsGroup:()=>J2,WuiDetailsGroupItem:()=>Za,WuiEmailInput:()=>m3,WuiFlex:()=>Gs,WuiGrid:()=>ki,WuiIcon:()=>l3,WuiIconBox:()=>Nt,WuiIconLink:()=>rl,WuiImage:()=>u3,WuiInputAmount:()=>cc,WuiInputElement:()=>n6,WuiInputNumeric:()=>xo,WuiInputText:()=>B1,WuiLink:()=>K0,WuiListAccordion:()=>ul,WuiListContent:()=>Nn,WuiListDescription:()=>So,WuiListItem:()=>Pr,WuiListNetwork:()=>rc,WuiListToken:()=>h1,WuiListWallet:()=>Xa,WuiListWalletTransaction:()=>j1,WuiLoadingHexagon:()=>Yc,WuiLoadingSpinner:()=>d3,WuiLoadingThumbnail:()=>B0,WuiLogo:()=>Q0,WuiLogoSelect:()=>sl,WuiNetworkButton:()=>M2,WuiNetworkImage:()=>Ts,WuiNoticeCard:()=>Da,WuiOnRampActivityItem:()=>Xs,WuiOnRampProviderItem:()=>Ot,WuiOtp:()=>al,WuiPreviewItem:()=>lc,WuiProfileButton:()=>G1,WuiPromo:()=>$e,WuiQrCode:()=>S2,WuiSearchBar:()=>J0,WuiSeparator:()=>In,WuiShimmer:()=>gt,WuiSnackbar:()=>E2,WuiTabs:()=>Qa,WuiTag:()=>U1,WuiText:()=>Xc,WuiTokenButton:()=>cl,WuiTokenListItem:()=>$1,WuiTooltip:()=>A2,WuiTooltipSelect:()=>W1,WuiTransactionListItem:()=>Ys,WuiTransactionListItemLoader:()=>X0,WuiTransactionVisual:()=>d1,WuiVisual:()=>qs,WuiVisualThumbnail:()=>ll,WuiWalletImage:()=>l1,convertInputMaskBottomSvg:()=>en,convertInputMaskTopSvg:()=>Mn,customElement:()=>Wt,initializeTheming:()=>mr,setColorTheme:()=>er,setThemeVariables:()=>O1});var Y=$(5861);const ce=globalThis,z=ce.ShadowRoot&&(void 0===ce.ShadyCSS||ce.ShadyCSS.nativeShadow)&&"adoptedStyleSheets"in Document.prototype&&"replace"in CSSStyleSheet.prototype,b=Symbol(),w=new WeakMap;class g{constructor(M,q,fe){if(this._$cssResult$=!0,fe!==b)throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");this.cssText=M,this.t=q}get styleSheet(){let M=this.o;const q=this.t;if(z&&void 0===M){const fe=void 0!==q&&1===q.length;fe&&(M=w.get(q)),void 0===M&&((this.o=M=new CSSStyleSheet).replaceSync(this.cssText),fe&&w.set(q,M))}return M}toString(){return this.cssText}}const p=ie=>new g("string"==typeof ie?ie:ie+"",void 0,b),x=(ie,...M)=>{const q=1===ie.length?ie[0]:M.reduce((fe,xe,G)=>fe+(Ie=>{if(!0===Ie._$cssResult$)return Ie.cssText;if("number"==typeof Ie)return Ie;throw Error("Value passed to 'css' function must be a 'css' function result: "+Ie+". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.")})(xe)+ie[G+1],ie[0]);return new g(q,ie,b)},E=z?ie=>ie:ie=>ie instanceof CSSStyleSheet?(M=>{let q="";for(const fe of M.cssRules)q+=fe.cssText;return p(q)})(ie):ie,{is:k,defineProperty:F,getOwnPropertyDescriptor:J,getOwnPropertyNames:R,getOwnPropertySymbols:ee,getPrototypeOf:oe}=Object,re=globalThis,Pe=re.trustedTypes,Re=Pe?Pe.emptyScript:"",De=re.reactiveElementPolyfillSupport,Ae=(ie,M)=>ie,Me={toAttribute(ie,M){switch(M){case Boolean:ie=ie?Re:null;break;case Object:case Array:ie=null==ie?ie:JSON.stringify(ie)}return ie},fromAttribute(ie,M){let q=ie;switch(M){case Boolean:q=null!==ie;break;case Number:q=null===ie?null:Number(ie);break;case Object:case Array:try{q=JSON.parse(ie)}catch{q=null}}return q}},he=(ie,M)=>!k(ie,M),me={attribute:!0,type:String,converter:Me,reflect:!1,hasChanged:he};Symbol.metadata??=Symbol("metadata"),re.litPropertyMetadata??=new WeakMap;class be extends HTMLElement{static addInitializer(M){this._$Ei(),(this.l??=[]).push(M)}static get observedAttributes(){return this.finalize(),this._$Eh&&[...this._$Eh.keys()]}static createProperty(M,q=me){if(q.state&&(q.attribute=!1),this._$Ei(),this.elementProperties.set(M,q),!q.noAccessor){const fe=Symbol(),xe=this.getPropertyDescriptor(M,fe,q);void 0!==xe&&F(this.prototype,M,xe)}}static getPropertyDescriptor(M,q,fe){const{get:xe,set:G}=J(this.prototype,M)??{get(){return this[q]},set(Ie){this[q]=Ie}};return{get(){return xe?.call(this)},set(Ie){const Ye=xe?.call(this);G.call(this,Ie),this.requestUpdate(M,Ye,fe)},configurable:!0,enumerable:!0}}static getPropertyOptions(M){return this.elementProperties.get(M)??me}static _$Ei(){if(this.hasOwnProperty(Ae("elementProperties")))return;const M=oe(this);M.finalize(),void 0!==M.l&&(this.l=[...M.l]),this.elementProperties=new Map(M.elementProperties)}static finalize(){if(this.hasOwnProperty(Ae("finalized")))return;if(this.finalized=!0,this._$Ei(),this.hasOwnProperty(Ae("properties"))){const q=this.properties,fe=[...R(q),...ee(q)];for(const xe of fe)this.createProperty(xe,q[xe])}const M=this[Symbol.metadata];if(null!==M){const q=litPropertyMetadata.get(M);if(void 0!==q)for(const[fe,xe]of q)this.elementProperties.set(fe,xe)}this._$Eh=new Map;for(const[q,fe]of this.elementProperties){const xe=this._$Eu(q,fe);void 0!==xe&&this._$Eh.set(xe,q)}this.elementStyles=this.finalizeStyles(this.styles)}static finalizeStyles(M){const q=[];if(Array.isArray(M)){const fe=new Set(M.flat(1/0).reverse());for(const xe of fe)q.unshift(E(xe))}else void 0!==M&&q.push(E(M));return q}static _$Eu(M,q){const fe=q.attribute;return!1===fe?void 0:"string"==typeof fe?fe:"string"==typeof M?M.toLowerCase():void 0}constructor(){super(),this._$Ep=void 0,this.isUpdatePending=!1,this.hasUpdated=!1,this._$Em=null,this._$Ev()}_$Ev(){this._$ES=new Promise(M=>this.enableUpdating=M),this._$AL=new Map,this._$E_(),this.requestUpdate(),this.constructor.l?.forEach(M=>M(this))}addController(M){(this._$EO??=new Set).add(M),void 0!==this.renderRoot&&this.isConnected&&M.hostConnected?.()}removeController(M){this._$EO?.delete(M)}_$E_(){const M=new Map,q=this.constructor.elementProperties;for(const fe of q.keys())this.hasOwnProperty(fe)&&(M.set(fe,this[fe]),delete this[fe]);M.size>0&&(this._$Ep=M)}createRenderRoot(){const M=this.shadowRoot??this.attachShadow(this.constructor.shadowRootOptions);return((ie,M)=>{if(z)ie.adoptedStyleSheets=M.map(q=>q instanceof CSSStyleSheet?q:q.styleSheet);else for(const q of M){const fe=document.createElement("style"),xe=ce.litNonce;void 0!==xe&&fe.setAttribute("nonce",xe),fe.textContent=q.cssText,ie.appendChild(fe)}})(M,this.constructor.elementStyles),M}connectedCallback(){this.renderRoot??=this.createRenderRoot(),this.enableUpdating(!0),this._$EO?.forEach(M=>M.hostConnected?.())}enableUpdating(M){}disconnectedCallback(){this._$EO?.forEach(M=>M.hostDisconnected?.())}attributeChangedCallback(M,q,fe){this._$AK(M,fe)}_$EC(M,q){const fe=this.constructor.elementProperties.get(M),xe=this.constructor._$Eu(M,fe);if(void 0!==xe&&!0===fe.reflect){const G=(void 0!==fe.converter?.toAttribute?fe.converter:Me).toAttribute(q,fe.type);this._$Em=M,null==G?this.removeAttribute(xe):this.setAttribute(xe,G),this._$Em=null}}_$AK(M,q){const fe=this.constructor,xe=fe._$Eh.get(M);if(void 0!==xe&&this._$Em!==xe){const G=fe.getPropertyOptions(xe),Ie="function"==typeof G.converter?{fromAttribute:G.converter}:void 0!==G.converter?.fromAttribute?G.converter:Me;this._$Em=xe,this[xe]=Ie.fromAttribute(q,G.type),this._$Em=null}}requestUpdate(M,q,fe){if(void 0!==M){if(fe??=this.constructor.getPropertyOptions(M),!(fe.hasChanged??he)(this[M],q))return;this.P(M,q,fe)}!1===this.isUpdatePending&&(this._$ES=this._$ET())}P(M,q,fe){this._$AL.has(M)||this._$AL.set(M,q),!0===fe.reflect&&this._$Em!==M&&(this._$Ej??=new Set).add(M)}_$ET(){var M=this;return(0,Y.Z)(function*(){M.isUpdatePending=!0;try{yield M._$ES}catch(fe){Promise.reject(fe)}const q=M.scheduleUpdate();return null!=q&&(yield q),!M.isUpdatePending})()}scheduleUpdate(){return this.performUpdate()}performUpdate(){if(!this.isUpdatePending)return;if(!this.hasUpdated){if(this.renderRoot??=this.createRenderRoot(),this._$Ep){for(const[xe,G]of this._$Ep)this[xe]=G;this._$Ep=void 0}const fe=this.constructor.elementProperties;if(fe.size>0)for(const[xe,G]of fe)!0!==G.wrapped||this._$AL.has(xe)||void 0===this[xe]||this.P(xe,this[xe],G)}let M=!1;const q=this._$AL;try{M=this.shouldUpdate(q),M?(this.willUpdate(q),this._$EO?.forEach(fe=>fe.hostUpdate?.()),this.update(q)):this._$EU()}catch(fe){throw M=!1,this._$EU(),fe}M&&this._$AE(q)}willUpdate(M){}_$AE(M){this._$EO?.forEach(q=>q.hostUpdated?.()),this.hasUpdated||(this.hasUpdated=!0,this.firstUpdated(M)),this.updated(M)}_$EU(){this._$AL=new Map,this.isUpdatePending=!1}get updateComplete(){return this.getUpdateComplete()}getUpdateComplete(){return this._$ES}shouldUpdate(M){return!0}update(M){this._$Ej&&=this._$Ej.forEach(q=>this._$EC(q,this[q])),this._$EU()}updated(M){}firstUpdated(M){}}be.elementStyles=[],be.shadowRootOptions={mode:"open"},be[Ae("elementProperties")]=new Map,be[Ae("finalized")]=new Map,De?.({ReactiveElement:be}),(re.reactiveElementVersions??=[]).push("2.0.4");const _e=globalThis,ge=_e.trustedTypes,ve=ge?ge.createPolicy("lit-html",{createHTML:ie=>ie}):void 0,K="$lit$",H=`lit$${Math.random().toFixed(9).slice(2)}$`,C="?"+H,j=`<${C}>`,te=document,W=()=>te.createComment(""),ae=ie=>null===ie||"object"!=typeof ie&&"function"!=typeof ie,ne=Array.isArray,se=ie=>ne(ie)||"function"==typeof ie?.[Symbol.iterator],U="[ \t\n\f\r]",S=/<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g,le=/-->/g,Ue=/>/g,Ze=RegExp(`>|${U}(?:([^\\s"'>=/]+)(${U}*=${U}*(?:[^ \t\n\f\r"'\`<>=]|("|')|))|$)`,"g"),Q=/'/g,Le=/"/g,ze=/^(?:script|style|textarea|title)$/i,pe=ie=>(M,...q)=>({_$litType$:ie,strings:M,values:q}),de=pe(1),ke=pe(2),Xe=Symbol.for("lit-noChange"),We=Symbol.for("lit-nothing"),ct=new WeakMap,st=te.createTreeWalker(te,129);function Je(ie,M){if(!Array.isArray(ie)||!ie.hasOwnProperty("raw"))throw Error("invalid template strings array");return void 0!==ve?ve.createHTML(M):M}const ft=(ie,M)=>{const q=ie.length-1,fe=[];let xe,G=2===M?"<svg>":"",Ie=S;for(let Ye=0;Ye<q;Ye++){const nn=ie[Ye];let yi,Wi,ji=-1,p1=0;for(;p1<nn.length&&(Ie.lastIndex=p1,Wi=Ie.exec(nn),null!==Wi);)p1=Ie.lastIndex,Ie===S?"!--"===Wi[1]?Ie=le:void 0!==Wi[1]?Ie=Ue:void 0!==Wi[2]?(ze.test(Wi[2])&&(xe=RegExp("</"+Wi[2],"g")),Ie=Ze):void 0!==Wi[3]&&(Ie=Ze):Ie===Ze?">"===Wi[0]?(Ie=xe??S,ji=-1):void 0===Wi[1]?ji=-2:(ji=Ie.lastIndex-Wi[2].length,yi=Wi[1],Ie=void 0===Wi[3]?Ze:'"'===Wi[3]?Le:Q):Ie===Le||Ie===Q?Ie=Ze:Ie===le||Ie===Ue?Ie=S:(Ie=Ze,xe=void 0);const eo=Ie===Ze&&ie[Ye+1].startsWith("/>")?" ":"";G+=Ie===S?nn+j:ji>=0?(fe.push(yi),nn.slice(0,ji)+K+nn.slice(ji)+H+eo):nn+H+(-2===ji?Ye:eo)}return[Je(ie,G+(ie[q]||"<?>")+(2===M?"</svg>":"")),fe]};class ot{constructor({strings:M,_$litType$:q},fe){let xe;this.parts=[];let G=0,Ie=0;const Ye=M.length-1,nn=this.parts,[yi,Wi]=ft(M,q);if(this.el=ot.createElement(yi,fe),st.currentNode=this.el.content,2===q){const ji=this.el.content.firstChild;ji.replaceWith(...ji.childNodes)}for(;null!==(xe=st.nextNode())&&nn.length<Ye;){if(1===xe.nodeType){if(xe.hasAttributes())for(const ji of xe.getAttributeNames())if(ji.endsWith(K)){const p1=Wi[Ie++],eo=xe.getAttribute(ji).split(H),D2=/([.?@])?(.*)/.exec(p1);nn.push({type:1,index:G,name:D2[2],strings:eo,ctor:"."===D2[1]?wt:"?"===D2[1]?_t:"@"===D2[1]?Mt:$t}),xe.removeAttribute(ji)}else ji.startsWith(H)&&(nn.push({type:6,index:G}),xe.removeAttribute(ji));if(ze.test(xe.tagName)){const ji=xe.textContent.split(H),p1=ji.length-1;if(p1>0){xe.textContent=ge?ge.emptyScript:"";for(let eo=0;eo<p1;eo++)xe.append(ji[eo],W()),st.nextNode(),nn.push({type:2,index:++G});xe.append(ji[p1],W())}}}else if(8===xe.nodeType)if(xe.data===C)nn.push({type:2,index:G});else{let ji=-1;for(;-1!==(ji=xe.data.indexOf(H,ji+1));)nn.push({type:7,index:G}),ji+=H.length-1}G++}}static createElement(M,q){const fe=te.createElement("template");return fe.innerHTML=M,fe}}function lt(ie,M,q=ie,fe){if(M===Xe)return M;let xe=void 0!==fe?q._$Co?.[fe]:q._$Cl;const G=ae(M)?void 0:M._$litDirective$;return xe?.constructor!==G&&(xe?._$AO?.(!1),void 0===G?xe=void 0:(xe=new G(ie),xe._$AT(ie,q,fe)),void 0!==fe?(q._$Co??=[])[fe]=xe:q._$Cl=xe),void 0!==xe&&(M=lt(ie,xe._$AS(ie,M.values),xe,fe)),M}class ht{constructor(M,q){this._$AV=[],this._$AN=void 0,this._$AD=M,this._$AM=q}get parentNode(){return this._$AM.parentNode}get _$AU(){return this._$AM._$AU}u(M){const{el:{content:q},parts:fe}=this._$AD,xe=(M?.creationScope??te).importNode(q,!0);st.currentNode=xe;let G=st.nextNode(),Ie=0,Ye=0,nn=fe[0];for(;void 0!==nn;){if(Ie===nn.index){let yi;2===nn.type?yi=new Lt(G,G.nextSibling,this,M):1===nn.type?yi=new nn.ctor(G,nn.name,nn.strings,this,M):6===nn.type&&(yi=new L(G,this,M)),this._$AV.push(yi),nn=fe[++Ye]}Ie!==nn?.index&&(G=st.nextNode(),Ie++)}return st.currentNode=te,xe}p(M){let q=0;for(const fe of this._$AV)void 0!==fe&&(void 0!==fe.strings?(fe._$AI(M,fe,q),q+=fe.strings.length-2):fe._$AI(M[q])),q++}}class Lt{get _$AU(){return this._$AM?._$AU??this._$Cv}constructor(M,q,fe,xe){this.type=2,this._$AH=We,this._$AN=void 0,this._$AA=M,this._$AB=q,this._$AM=fe,this.options=xe,this._$Cv=xe?.isConnected??!0}get parentNode(){let M=this._$AA.parentNode;const q=this._$AM;return void 0!==q&&11===M?.nodeType&&(M=q.parentNode),M}get startNode(){return this._$AA}get endNode(){return this._$AB}_$AI(M,q=this){M=lt(this,M,q),ae(M)?M===We||null==M||""===M?(this._$AH!==We&&this._$AR(),this._$AH=We):M!==this._$AH&&M!==Xe&&this._(M):void 0!==M._$litType$?this.$(M):void 0!==M.nodeType?this.T(M):se(M)?this.k(M):this._(M)}S(M){return this._$AA.parentNode.insertBefore(M,this._$AB)}T(M){this._$AH!==M&&(this._$AR(),this._$AH=this.S(M))}_(M){this._$AH!==We&&ae(this._$AH)?this._$AA.nextSibling.data=M:this.T(te.createTextNode(M)),this._$AH=M}$(M){const{values:q,_$litType$:fe}=M,xe="number"==typeof fe?this._$AC(M):(void 0===fe.el&&(fe.el=ot.createElement(Je(fe.h,fe.h[0]),this.options)),fe);if(this._$AH?._$AD===xe)this._$AH.p(q);else{const G=new ht(xe,this),Ie=G.u(this.options);G.p(q),this.T(Ie),this._$AH=G}}_$AC(M){let q=ct.get(M.strings);return void 0===q&&ct.set(M.strings,q=new ot(M)),q}k(M){ne(this._$AH)||(this._$AH=[],this._$AR());const q=this._$AH;let fe,xe=0;for(const G of M)xe===q.length?q.push(fe=new Lt(this.S(W()),this.S(W()),this,this.options)):fe=q[xe],fe._$AI(G),xe++;xe<q.length&&(this._$AR(fe&&fe._$AB.nextSibling,xe),q.length=xe)}_$AR(M=this._$AA.nextSibling,q){for(this._$AP?.(!1,!0,q);M&&M!==this._$AB;){const fe=M.nextSibling;M.remove(),M=fe}}setConnected(M){void 0===this._$AM&&(this._$Cv=M,this._$AP?.(M))}}class $t{get tagName(){return this.element.tagName}get _$AU(){return this._$AM._$AU}constructor(M,q,fe,xe,G){this.type=1,this._$AH=We,this._$AN=void 0,this.element=M,this.name=q,this._$AM=xe,this.options=G,fe.length>2||""!==fe[0]||""!==fe[1]?(this._$AH=Array(fe.length-1).fill(new String),this.strings=fe):this._$AH=We}_$AI(M,q=this,fe,xe){const G=this.strings;let Ie=!1;if(void 0===G)M=lt(this,M,q,0),Ie=!ae(M)||M!==this._$AH&&M!==Xe,Ie&&(this._$AH=M);else{const Ye=M;let nn,yi;for(M=G[0],nn=0;nn<G.length-1;nn++)yi=lt(this,Ye[fe+nn],q,nn),yi===Xe&&(yi=this._$AH[nn]),Ie||=!ae(yi)||yi!==this._$AH[nn],yi===We?M=We:M!==We&&(M+=(yi??"")+G[nn+1]),this._$AH[nn]=yi}Ie&&!xe&&this.j(M)}j(M){M===We?this.element.removeAttribute(this.name):this.element.setAttribute(this.name,M??"")}}class wt extends $t{constructor(){super(...arguments),this.type=3}j(M){this.element[this.name]=M===We?void 0:M}}class _t extends $t{constructor(){super(...arguments),this.type=4}j(M){this.element.toggleAttribute(this.name,!!M&&M!==We)}}class Mt extends $t{constructor(M,q,fe,xe,G){super(M,q,fe,xe,G),this.type=5}_$AI(M,q=this){if((M=lt(this,M,q,0)??We)===Xe)return;const fe=this._$AH,xe=M===We&&fe!==We||M.capture!==fe.capture||M.once!==fe.once||M.passive!==fe.passive,G=M!==We&&(fe===We||xe);xe&&this.element.removeEventListener(this.name,this,fe),G&&this.element.addEventListener(this.name,this,M),this._$AH=M}handleEvent(M){"function"==typeof this._$AH?this._$AH.call(this.options?.host??this.element,M):this._$AH.handleEvent(M)}}class L{constructor(M,q,fe){this.element=M,this.type=6,this._$AN=void 0,this._$AM=q,this.options=fe}get _$AU(){return this._$AM._$AU}_$AI(M){lt(this,M)}}const N={P:K,A:H,C,M:1,L:ft,R:ht,D:se,V:lt,I:Lt,H:$t,N:_t,U:Mt,B:wt,F:L},X=_e.litHtmlPolyfillSupport;X?.(ot,Lt),(_e.litHtmlVersions??=[]).push("3.1.3");class Be extends be{constructor(){super(...arguments),this.renderOptions={host:this},this._$Do=void 0}createRenderRoot(){const M=super.createRenderRoot();return this.renderOptions.renderBefore??=M.firstChild,M}update(M){const q=this.render();this.hasUpdated||(this.renderOptions.isConnected=this.isConnected),super.update(M),this._$Do=((ie,M,q)=>{const fe=q?.renderBefore??M;let xe=fe._$litPart$;if(void 0===xe){const G=q?.renderBefore??null;fe._$litPart$=xe=new Lt(M.insertBefore(W(),G),G,void 0,q??{})}return xe._$AI(ie),xe})(q,this.renderRoot,this.renderOptions)}connectedCallback(){super.connectedCallback(),this._$Do?.setConnected(!0)}disconnectedCallback(){super.disconnectedCallback(),this._$Do?.setConnected(!1)}render(){return Xe}}Be._$litElement$=!0,Be.finalized=!0,globalThis.litElementHydrateSupport?.({LitElement:Be});const pt=globalThis.litElementPolyfillSupport;pt?.({LitElement:Be}),(globalThis.litElementVersions??=[]).push("4.0.5");const en=ke`<svg class="input_mask" width="328" height="100" viewBox="0 0 328 100" fill="none">
  <mask id="path-1-inside-1_18299_4189">
    <path
      class="input_mask__border"
      fill-rule="evenodd"
      clip-rule="evenodd"
      d="M138.008 0H40C21.1438 0 11.7157 0 5.85786 5.85786C0 11.7157 0 21.1438 0 40V60C0 78.8562 0 88.2843 5.85786 94.1421C11.7157 100 21.1438 100 40 100H288C306.856 100 316.284 100 322.142 94.1421C328 88.2843 328 78.8562 328 60V40C328 21.1438 328 11.7157 322.142 5.85786C316.284 0 306.856 0 288 0H189.992C189.958 4.89122 189.786 7.76279 188.914 10.1564C187.095 15.1562 183.156 19.0947 178.156 20.9145C175.174 22 171.449 22 164 22C156.551 22 152.826 22 149.844 20.9145C144.844 19.0947 140.905 15.1562 139.086 10.1564C138.214 7.76279 138.042 4.89122 138.008 0Z"
    />
  </mask>
  <path
    class="input_mask__background"
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M138.008 0H40C21.1438 0 11.7157 0 5.85786 5.85786C0 11.7157 0 21.1438 0 40V60C0 78.8562 0 88.2843 5.85786 94.1421C11.7157 100 21.1438 100 40 100H288C306.856 100 316.284 100 322.142 94.1421C328 88.2843 328 78.8562 328 60V40C328 21.1438 328 11.7157 322.142 5.85786C316.284 0 306.856 0 288 0H189.992C189.958 4.89122 189.786 7.76279 188.914 10.1564C187.095 15.1562 183.156 19.0947 178.156 20.9145C175.174 22 171.449 22 164 22C156.551 22 152.826 22 149.844 20.9145C144.844 19.0947 140.905 15.1562 139.086 10.1564C138.214 7.76279 138.042 4.89122 138.008 0Z"
  />
  <path
    class="input_mask__border"
    d="M138.008 0L139.008 -0.00694413L139.001 -1H138.008V0ZM322.142 94.1421L322.849 94.8492H322.849L322.142 94.1421ZM322.142 5.85786L322.849 5.15076L322.849 5.15076L322.142 5.85786ZM189.992 0V-1H188.999L188.992 -0.00694413L189.992 0ZM188.914 10.1564L189.854 10.4984V10.4984L188.914 10.1564ZM178.156 20.9145L177.814 19.9748V19.9748L178.156 20.9145ZM149.844 20.9145L150.186 19.9748V19.9748L149.844 20.9145ZM139.086 10.1564L138.146 10.4984V10.4984L139.086 10.1564ZM40 1H138.008V-1H40V1ZM6.56497 6.56497C9.27713 3.85281 12.8524 2.44064 18.1878 1.72332C23.552 1.00212 30.5436 1 40 1V-1C30.6002 -1 23.4497 -1.00212 17.9213 -0.25885C12.3641 0.488292 8.29646 2.00506 5.15076 5.15076L6.56497 6.56497ZM1 40C1 30.5436 1.00212 23.552 1.72332 18.1878C2.44064 12.8524 3.85281 9.27713 6.56497 6.56497L5.15076 5.15076C2.00506 8.29646 0.488292 12.3641 -0.25885 17.9213C-1.00212 23.4497 -1 30.6002 -1 40H1ZM1 60V40H-1V60H1ZM6.56497 93.435C3.85281 90.7229 2.44064 87.1476 1.72332 81.8122C1.00212 76.448 1 69.4564 1 60H-1C-1 69.3998 -1.00212 76.5503 -0.25885 82.0787C0.488292 87.6358 2.00506 91.7035 5.15076 94.8492L6.56497 93.435ZM40 99C30.5436 99 23.552 98.9979 18.1878 98.2767C12.8524 97.5594 9.27713 96.1472 6.56497 93.435L5.15076 94.8492C8.29646 97.9949 12.3641 99.5117 17.9213 100.259C23.4497 101.002 30.6002 101 40 101V99ZM288 99H40V101H288V99ZM321.435 93.435C318.723 96.1472 315.148 97.5594 309.812 98.2767C304.448 98.9979 297.456 99 288 99V101C297.4 101 304.55 101.002 310.079 100.259C315.636 99.5117 319.704 97.9949 322.849 94.8492L321.435 93.435ZM327 60C327 69.4564 326.998 76.448 326.277 81.8122C325.559 87.1476 324.147 90.7229 321.435 93.435L322.849 94.8492C325.995 91.7035 327.512 87.6358 328.259 82.0787C329.002 76.5503 329 69.3998 329 60H327ZM327 40V60H329V40H327ZM321.435 6.56497C324.147 9.27713 325.559 12.8524 326.277 18.1878C326.998 23.552 327 30.5436 327 40H329C329 30.6002 329.002 23.4497 328.259 17.9213C327.512 12.3642 325.995 8.29646 322.849 5.15076L321.435 6.56497ZM288 1C297.456 1 304.448 1.00212 309.812 1.72332C315.148 2.44064 318.723 3.85281 321.435 6.56497L322.849 5.15076C319.704 2.00506 315.636 0.488292 310.079 -0.25885C304.55 -1.00212 297.4 -1 288 -1V1ZM189.992 1H288V-1H189.992V1ZM188.992 -0.00694413C188.958 4.90792 188.778 7.60788 187.975 9.81434L189.854 10.4984C190.793 7.9177 190.958 4.87452 190.992 0.00694413L188.992 -0.00694413ZM187.975 9.81434C186.256 14.5364 182.536 18.2561 177.814 19.9748L178.498 21.8542C183.776 19.9333 187.933 15.7759 189.854 10.4984L187.975 9.81434ZM177.814 19.9748C175.039 20.9848 171.536 21 164 21V23C171.362 23 175.308 23.0152 178.498 21.8542L177.814 19.9748ZM164 21C156.464 21 152.961 20.9848 150.186 19.9748L149.502 21.8542C152.692 23.0152 156.638 23 164 23V21ZM150.186 19.9748C145.464 18.2561 141.744 14.5364 140.025 9.81434L138.146 10.4984C140.067 15.7759 144.224 19.9333 149.502 21.8542L150.186 19.9748ZM140.025 9.81434C139.222 7.60788 139.042 4.90792 139.008 -0.00694413L137.008 0.00694413C137.042 4.87452 137.207 7.9177 138.146 10.4984L140.025 9.81434Z"
    mask="url(#path-1-inside-1_18299_4189)"
  />
</svg>`,Mn=ke`<svg class="input_mask" width="328" height="100" viewBox="0 0 328 100" fill="none">
  <mask id="path-1-inside-1_18299_4168">
    <path
      class="input_mask__border"
      fill-rule="evenodd"
      clip-rule="evenodd"
      d="M5.85786 5.85786C0 11.7157 0 21.1438 0 40V60C0 78.8562 0 88.2843 5.85786 94.1421C11.7157 100 21.1438 100 40 100H138.008C138.042 95.1088 138.214 92.2372 139.086 89.8436C140.905 84.8438 144.844 80.9053 149.844 79.0855C152.826 78 156.551 78 164 78C171.449 78 175.174 78 178.156 79.0855C183.156 80.9053 187.095 84.8438 188.914 89.8436C189.786 92.2372 189.958 95.1088 189.992 100H288C306.856 100 316.284 100 322.142 94.1421C328 88.2843 328 78.8562 328 60V40C328 21.1438 328 11.7157 322.142 5.85786C316.284 0 306.856 0 288 0H40C21.1438 0 11.7157 0 5.85786 5.85786Z"
    />
  </mask>
  <path
    class="input_mask__background"
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M5.85786 5.85786C0 11.7157 0 21.1438 0 40V60C0 78.8562 0 88.2843 5.85786 94.1421C11.7157 100 21.1438 100 40 100H138.008C138.042 95.1088 138.214 92.2372 139.086 89.8436C140.905 84.8438 144.844 80.9053 149.844 79.0855C152.826 78 156.551 78 164 78C171.449 78 175.174 78 178.156 79.0855C183.156 80.9053 187.095 84.8438 188.914 89.8436C189.786 92.2372 189.958 95.1088 189.992 100H288C306.856 100 316.284 100 322.142 94.1421C328 88.2843 328 78.8562 328 60V40C328 21.1438 328 11.7157 322.142 5.85786C316.284 0 306.856 0 288 0H40C21.1438 0 11.7157 0 5.85786 5.85786Z"
  />
  <path
    class="input_mask__border"
    d="M138.008 100V101H139.001L139.008 100.007L138.008 100ZM139.086 89.8436L138.146 89.5016L139.086 89.8436ZM149.844 79.0855L150.186 80.0252L149.844 79.0855ZM178.156 79.0855L177.814 80.0252L178.156 79.0855ZM188.914 89.8436L189.854 89.5016L188.914 89.8436ZM189.992 100L188.992 100.007L188.999 101H189.992V100ZM322.142 94.1421L322.849 94.8492H322.849L322.142 94.1421ZM322.142 5.85786L322.849 5.15076L322.849 5.15076L322.142 5.85786ZM1 40C1 30.5436 1.00212 23.552 1.72332 18.1878C2.44064 12.8524 3.85281 9.27713 6.56497 6.56497L5.15076 5.15076C2.00506 8.29646 0.488292 12.3641 -0.25885 17.9213C-1.00212 23.4497 -1 30.6002 -1 40H1ZM1 60V40H-1V60H1ZM6.56497 93.435C3.85281 90.7229 2.44064 87.1476 1.72332 81.8122C1.00212 76.448 1 69.4564 1 60H-1C-1 69.3998 -1.00212 76.5503 -0.25885 82.0787C0.488292 87.6358 2.00506 91.7035 5.15076 94.8492L6.56497 93.435ZM40 99C30.5436 99 23.552 98.9979 18.1878 98.2767C12.8524 97.5594 9.27713 96.1472 6.56497 93.435L5.15076 94.8492C8.29646 97.9949 12.3641 99.5117 17.9213 100.259C23.4497 101.002 30.6002 101 40 101V99ZM138.008 99H40V101H138.008V99ZM139.008 100.007C139.042 95.0921 139.222 92.3921 140.025 90.1857L138.146 89.5016C137.207 92.0823 137.042 95.1255 137.008 99.9931L139.008 100.007ZM140.025 90.1857C141.744 85.4636 145.464 81.7439 150.186 80.0252L149.502 78.1458C144.224 80.0667 140.067 84.2241 138.146 89.5016L140.025 90.1857ZM150.186 80.0252C152.961 79.0152 156.464 79 164 79V77C156.638 77 152.692 76.9848 149.502 78.1458L150.186 80.0252ZM164 79C171.536 79 175.039 79.0152 177.814 80.0252L178.498 78.1458C175.308 76.9848 171.362 77 164 77V79ZM177.814 80.0252C182.536 81.7439 186.256 85.4636 187.975 90.1857L189.854 89.5016C187.933 84.2241 183.776 80.0667 178.498 78.1458L177.814 80.0252ZM187.975 90.1857C188.778 92.3921 188.958 95.0921 188.992 100.007L190.992 99.9931C190.958 95.1255 190.793 92.0823 189.854 89.5016L187.975 90.1857ZM288 99H189.992V101H288V99ZM321.435 93.435C318.723 96.1472 315.148 97.5594 309.812 98.2767C304.448 98.9979 297.456 99 288 99V101C297.4 101 304.55 101.002 310.079 100.259C315.636 99.5117 319.704 97.9949 322.849 94.8492L321.435 93.435ZM327 60C327 69.4564 326.998 76.448 326.277 81.8122C325.559 87.1476 324.147 90.7229 321.435 93.435L322.849 94.8492C325.995 91.7035 327.512 87.6358 328.259 82.0787C329.002 76.5503 329 69.3998 329 60H327ZM327 40V60H329V40H327ZM321.435 6.56497C324.147 9.27713 325.559 12.8524 326.277 18.1878C326.998 23.552 327 30.5436 327 40H329C329 30.6002 329.002 23.4497 328.259 17.9213C327.512 12.3642 325.995 8.29646 322.849 5.15076L321.435 6.56497ZM288 1C297.456 1 304.448 1.00212 309.812 1.72332C315.148 2.44064 318.723 3.85281 321.435 6.56497L322.849 5.15076C319.704 2.00506 315.636 0.488292 310.079 -0.25885C304.55 -1.00212 297.4 -1 288 -1V1ZM40 1H288V-1H40V1ZM6.56497 6.56497C9.27713 3.85281 12.8524 2.44064 18.1878 1.72332C23.552 1.00212 30.5436 1 40 1V-1C30.6002 -1 23.4497 -1.00212 17.9213 -0.25885C12.3641 0.488292 8.29646 2.00506 5.15076 5.15076L6.56497 6.56497Z"
    mask="url(#path-1-inside-1_18299_4168)"
  />
</svg>`;let rn,Qt,Zn;function mr(ie,M){rn=document.createElement("style"),Qt=document.createElement("style"),Zn=document.createElement("style"),rn.textContent=Ui(ie).core.cssText,Qt.textContent=Ui(ie).dark.cssText,Zn.textContent=Ui(ie).light.cssText,document.head.appendChild(rn),document.head.appendChild(Qt),document.head.appendChild(Zn),er(M)}function er(ie){Qt&&Zn&&("light"===ie?(Qt.removeAttribute("media"),Zn.media="enabled"):(Zn.removeAttribute("media"),Qt.media="enabled"))}function O1(ie){rn&&Qt&&Zn&&(rn.textContent=Ui(ie).core.cssText,Qt.textContent=Ui(ie).dark.cssText,Zn.textContent=Ui(ie).light.cssText)}function Ui(ie){return{core:x`
      @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
      :root {
        --w3m-color-mix-strength: ${p(ie?.["--w3m-color-mix-strength"]?`${ie["--w3m-color-mix-strength"]}%`:"0%")};
        --w3m-font-family: ${p(ie?.["--w3m-font-family"]||"Inter, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue, sans-serif;")};
        --w3m-font-size-master: ${p(ie?.["--w3m-font-size-master"]||"10px")};
        --w3m-border-radius-master: ${p(ie?.["--w3m-border-radius-master"]||"4px")};
        --w3m-z-index: ${p(ie?.["--w3m-z-index"]||999)};

        --wui-font-family: var(--w3m-font-family);

        --wui-font-size-mini: calc(var(--w3m-font-size-master) * 0.8);
        --wui-font-size-micro: var(--w3m-font-size-master);
        --wui-font-size-tiny: calc(var(--w3m-font-size-master) * 1.2);
        --wui-font-size-small: calc(var(--w3m-font-size-master) * 1.4);
        --wui-font-size-paragraph: calc(var(--w3m-font-size-master) * 1.6);
        --wui-font-size-medium: calc(var(--w3m-font-size-master) * 1.8);
        --wui-font-size-large: calc(var(--w3m-font-size-master) * 2);
        --wui-font-size-medium-title: calc(var(--w3m-font-size-master) * 2.4);
        --wui-font-size-2xl: calc(var(--w3m-font-size-master) * 4);

        --wui-border-radius-5xs: var(--w3m-border-radius-master);
        --wui-border-radius-4xs: calc(var(--w3m-border-radius-master) * 1.5);
        --wui-border-radius-3xs: calc(var(--w3m-border-radius-master) * 2);
        --wui-border-radius-xxs: calc(var(--w3m-border-radius-master) * 3);
        --wui-border-radius-xs: calc(var(--w3m-border-radius-master) * 4);
        --wui-border-radius-s: calc(var(--w3m-border-radius-master) * 5);
        --wui-border-radius-m: calc(var(--w3m-border-radius-master) * 7);
        --wui-border-radius-l: calc(var(--w3m-border-radius-master) * 9);
        --wui-border-radius-3xl: calc(var(--w3m-border-radius-master) * 20);

        --wui-font-weight-light: 400;
        --wui-font-weight-regular: 500;
        --wui-font-weight-medium: 600;
        --wui-font-weight-bold: 700;

        --wui-letter-spacing-2xl: -1.6px;
        --wui-letter-spacing-medium-title: -0.96px;
        --wui-letter-spacing-large: -0.8px;
        --wui-letter-spacing-medium: -0.72px;
        --wui-letter-spacing-paragraph: -0.64px;
        --wui-letter-spacing-small: -0.56px;
        --wui-letter-spacing-tiny: -0.48px;
        --wui-letter-spacing-micro: -0.2px;
        --wui-letter-spacing-mini: -0.16px;

        --wui-spacing-0: 0px;
        --wui-spacing-4xs: 2px;
        --wui-spacing-3xs: 4px;
        --wui-spacing-xxs: 6px;
        --wui-spacing-2xs: 7px;
        --wui-spacing-xs: 8px;
        --wui-spacing-1xs: 10px;
        --wui-spacing-s: 12px;
        --wui-spacing-m: 14px;
        --wui-spacing-l: 16px;
        --wui-spacing-2l: 18px;
        --wui-spacing-xl: 20px;
        --wui-spacing-xxl: 24px;
        --wui-spacing-2xl: 32px;
        --wui-spacing-3xl: 40px;
        --wui-spacing-4xl: 90px;

        --wui-icon-box-size-xxs: 14px;
        --wui-icon-box-size-xs: 20px;
        --wui-icon-box-size-sm: 24px;
        --wui-icon-box-size-md: 32px;
        --wui-icon-box-size-lg: 40px;
        --wui-icon-box-size-xl: 64px;

        --wui-icon-size-inherit: inherit;
        --wui-icon-size-xxs: 10px;
        --wui-icon-size-xs: 12px;
        --wui-icon-size-sm: 14px;
        --wui-icon-size-md: 16px;
        --wui-icon-size-mdl: 18px;
        --wui-icon-size-lg: 20px;
        --wui-icon-size-xl: 24px;

        --wui-wallet-image-size-inherit: inherit;
        --wui-wallet-image-size-sm: 40px;
        --wui-wallet-image-size-md: 56px;
        --wui-wallet-image-size-lg: 80px;

        --wui-visual-size-size-inherit: inherit;
        --wui-visual-size-sm: 40px;
        --wui-visual-size-md: 55px;
        --wui-visual-size-lg: 80px;

        --wui-box-size-md: 100px;
        --wui-box-size-lg: 120px;

        --wui-ease-out-power-2: cubic-bezier(0, 0, 0.22, 1);
        --wui-ease-out-power-1: cubic-bezier(0, 0, 0.55, 1);

        --wui-ease-in-power-3: cubic-bezier(0.66, 0, 1, 1);
        --wui-ease-in-power-2: cubic-bezier(0.45, 0, 1, 1);
        --wui-ease-in-power-1: cubic-bezier(0.3, 0, 1, 1);

        --wui-ease-inout-power-1: cubic-bezier(0.45, 0, 0.55, 1);

        --wui-duration-lg: 200ms;
        --wui-duration-md: 125ms;
        --wui-duration-sm: 75ms;

        --wui-path-network-sm: path(
          'M15.4 2.1a5.21 5.21 0 0 1 5.2 0l11.61 6.7a5.21 5.21 0 0 1 2.61 4.52v13.4c0 1.87-1 3.59-2.6 4.52l-11.61 6.7c-1.62.93-3.6.93-5.22 0l-11.6-6.7a5.21 5.21 0 0 1-2.61-4.51v-13.4c0-1.87 1-3.6 2.6-4.52L15.4 2.1Z'
        );

        --wui-path-network-md: path(
          'M43.4605 10.7248L28.0485 1.61089C25.5438 0.129705 22.4562 0.129705 19.9515 1.61088L4.53951 10.7248C2.03626 12.2051 0.5 14.9365 0.5 17.886V36.1139C0.5 39.0635 2.03626 41.7949 4.53951 43.2752L19.9515 52.3891C22.4562 53.8703 25.5438 53.8703 28.0485 52.3891L43.4605 43.2752C45.9637 41.7949 47.5 39.0635 47.5 36.114V17.8861C47.5 14.9365 45.9637 12.2051 43.4605 10.7248Z'
        );

        --wui-path-network-lg: path(
          'M78.3244 18.926L50.1808 2.45078C45.7376 -0.150261 40.2624 -0.150262 35.8192 2.45078L7.6756 18.926C3.23322 21.5266 0.5 26.3301 0.5 31.5248V64.4752C0.5 69.6699 3.23322 74.4734 7.6756 77.074L35.8192 93.5492C40.2624 96.1503 45.7376 96.1503 50.1808 93.5492L78.3244 77.074C82.7668 74.4734 85.5 69.6699 85.5 64.4752V31.5248C85.5 26.3301 82.7668 21.5266 78.3244 18.926Z'
        );

        --wui-width-network-sm: 36px;
        --wui-width-network-md: 48px;
        --wui-width-network-lg: 86px;

        --wui-height-network-sm: 40px;
        --wui-height-network-md: 54px;
        --wui-height-network-lg: 96px;

        --wui-icon-size-network-xs: 12px;
        --wui-icon-size-network-sm: 16px;
        --wui-icon-size-network-md: 24px;
        --wui-icon-size-network-lg: 42px;

        --wui-color-inherit: inherit;

        --wui-color-inverse-100: #fff;
        --wui-color-inverse-000: #000;

        --wui-cover: rgba(20, 20, 20, 0.8);

        --wui-color-modal-bg: var(--wui-color-modal-bg-base);

        --wui-color-blue-100: var(--wui-color-blue-base-100);

        --wui-color-accent-100: var(--wui-color-accent-base-100);
        --wui-color-accent-090: var(--wui-color-accent-base-090);
        --wui-color-accent-080: var(--wui-color-accent-base-080);

        --wui-accent-glass-090: var(--wui-accent-glass-base-090);
        --wui-accent-glass-080: var(--wui-accent-glass-base-080);
        --wui-accent-glass-020: var(--wui-accent-glass-base-020);
        --wui-accent-glass-015: var(--wui-accent-glass-base-015);
        --wui-accent-glass-010: var(--wui-accent-glass-base-010);
        --wui-accent-glass-005: var(--wui-accent-glass-base-005);
        --wui-accent-glass-002: var(--wui-accent-glass-base-002);

        --wui-color-fg-100: var(--wui-color-fg-base-100);
        --wui-color-fg-125: var(--wui-color-fg-base-125);
        --wui-color-fg-150: var(--wui-color-fg-base-150);
        --wui-color-fg-175: var(--wui-color-fg-base-175);
        --wui-color-fg-200: var(--wui-color-fg-base-200);
        --wui-color-fg-225: var(--wui-color-fg-base-225);
        --wui-color-fg-250: var(--wui-color-fg-base-250);
        --wui-color-fg-275: var(--wui-color-fg-base-275);
        --wui-color-fg-300: var(--wui-color-fg-base-300);

        --wui-color-bg-100: var(--wui-color-bg-base-100);
        --wui-color-bg-125: var(--wui-color-bg-base-125);
        --wui-color-bg-150: var(--wui-color-bg-base-150);
        --wui-color-bg-175: var(--wui-color-bg-base-175);
        --wui-color-bg-200: var(--wui-color-bg-base-200);
        --wui-color-bg-225: var(--wui-color-bg-base-225);
        --wui-color-bg-250: var(--wui-color-bg-base-250);
        --wui-color-bg-275: var(--wui-color-bg-base-275);
        --wui-color-bg-300: var(--wui-color-bg-base-300);

        --wui-color-success-100: var(--wui-color-success-base-100);
        --wui-color-error-100: var(--wui-color-error-base-100);

        --wui-icon-box-bg-error-100: var(--wui-icon-box-bg-error-base-100);
        --wui-icon-box-bg-blue-100: var(--wui-icon-box-bg-blue-base-100);
        --wui-icon-box-bg-success-100: var(--wui-icon-box-bg-success-base-100);
        --wui-icon-box-bg-inverse-100: var(--wui-icon-box-bg-inverse-base-100);

        --wui-all-wallets-bg-100: var(--wui-all-wallets-bg-base-100);

        --wui-avatar-border: var(--wui-avatar-border-base);

        --wui-thumbnail-border: var(--wui-thumbnail-border-base);

        --wui-box-shadow-blue: rgba(71, 161, 255, 0.16);
      }

      @supports (background: color-mix(in srgb, white 50%, black)) {
        :root {
          --wui-color-modal-bg: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-modal-bg-base)
          );

          --wui-box-shadow-blue: color-mix(in srgb, var(--wui-color-accent-100) 16%, transparent);

          --wui-color-accent-090: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 90%,
            var(--w3m-default)
          );
          --wui-color-accent-080: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 80%,
            var(--w3m-default)
          );

          --wui-color-accent-090: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 90%,
            transparent
          );
          --wui-color-accent-080: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 80%,
            transparent
          );

          --wui-accent-glass-090: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 90%,
            transparent
          );
          --wui-accent-glass-080: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 80%,
            transparent
          );
          --wui-accent-glass-020: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 20%,
            transparent
          );
          --wui-accent-glass-015: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 15%,
            transparent
          );
          --wui-accent-glass-010: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 10%,
            transparent
          );
          --wui-accent-glass-005: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 5%,
            transparent
          );
          --wui-color-accent-002: color-mix(
            in srgb,
            var(--wui-color-accent-base-100) 2%,
            transparent
          );

          --wui-color-fg-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-100)
          );
          --wui-color-fg-125: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-125)
          );
          --wui-color-fg-150: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-150)
          );
          --wui-color-fg-175: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-175)
          );
          --wui-color-fg-200: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-200)
          );
          --wui-color-fg-225: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-225)
          );
          --wui-color-fg-250: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-250)
          );
          --wui-color-fg-275: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-275)
          );
          --wui-color-fg-300: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-fg-base-300)
          );

          --wui-color-bg-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-100)
          );
          --wui-color-bg-125: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-125)
          );
          --wui-color-bg-150: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-150)
          );
          --wui-color-bg-175: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-175)
          );
          --wui-color-bg-200: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-200)
          );
          --wui-color-bg-225: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-225)
          );
          --wui-color-bg-250: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-250)
          );
          --wui-color-bg-275: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-275)
          );
          --wui-color-bg-300: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-bg-base-300)
          );

          --wui-color-success-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-success-base-100)
          );
          --wui-color-error-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-color-error-base-100)
          );

          --wui-icon-box-bg-error-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-icon-box-bg-error-base-100)
          );
          --wui-icon-box-bg-accent-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-icon-box-bg-blue-base-100)
          );
          --wui-icon-box-bg-success-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-icon-box-bg-success-base-100)
          );
          --wui-icon-box-bg-inverse-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-icon-box-bg-inverse-base-100)
          );

          --wui-all-wallets-bg-100: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-all-wallets-bg-base-100)
          );

          --wui-avatar-border: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-avatar-border-base)
          );

          --wui-thumbnail-border: color-mix(
            in srgb,
            var(--w3m-color-mix) var(--w3m-color-mix-strength),
            var(--wui-thumbnail-border-base)
          );
        }
      }
    `,light:x`
      :root {
        --w3m-color-mix: ${p(ie?.["--w3m-color-mix"]||"#fff")};
        --w3m-accent: ${p(ie?.["--w3m-accent"]||"#47a1ff")};
        --w3m-default: #fff;

        --wui-color-modal-bg-base: #191a1a;

        --wui-color-blue-base-100: #47a1ff;

        --wui-color-accent-base-100: var(--w3m-accent);
        --wui-color-accent-base-090: #59aaff;
        --wui-color-accent-base-080: #6cb4ff;

        --wui-accent-glass-base-090: rgba(71, 161, 255, 0.9);
        --wui-accent-glass-base-080: rgba(71, 161, 255, 0.8);
        --wui-accent-glass-base-020: rgba(71, 161, 255, 0.2);
        --wui-accent-glass-base-015: rgba(71, 161, 255, 0.15);
        --wui-accent-glass-base-010: rgba(71, 161, 255, 0.1);
        --wui-accent-glass-base-005: rgba(71, 161, 255, 0.05);
        --wui-accent-glass-base-002: rgba(71, 161, 255, 0.02);

        --wui-color-fg-base-100: #e4e7e7;
        --wui-color-fg-base-125: #d0d5d5;
        --wui-color-fg-base-150: #a8b1b1;
        --wui-color-fg-base-175: #a8b0b0;
        --wui-color-fg-base-200: #949e9e;
        --wui-color-fg-base-225: #868f8f;
        --wui-color-fg-base-250: #788080;
        --wui-color-fg-base-275: #788181;
        --wui-color-fg-base-300: #6e7777;

        --wui-color-bg-base-100: #141414;
        --wui-color-bg-base-125: #191a1a;
        --wui-color-bg-base-150: #1e1f1f;
        --wui-color-bg-base-175: #222525;
        --wui-color-bg-base-200: #272a2a;
        --wui-color-bg-base-225: #2c3030;
        --wui-color-bg-base-250: #313535;
        --wui-color-bg-base-275: #363b3b;
        --wui-color-bg-base-300: #3b4040;

        --wui-color-success-base-100: #26d962;
        --wui-color-error-base-100: #f25a67;

        --wui-success-glass-001: rgba(38, 217, 98, 0.01);
        --wui-success-glass-002: rgba(38, 217, 98, 0.02);
        --wui-success-glass-005: rgba(38, 217, 98, 0.05);
        --wui-success-glass-010: rgba(38, 217, 98, 0.1);
        --wui-success-glass-015: rgba(38, 217, 98, 0.15);
        --wui-success-glass-020: rgba(38, 217, 98, 0.2);
        --wui-success-glass-025: rgba(38, 217, 98, 0.25);
        --wui-success-glass-030: rgba(38, 217, 98, 0.3);
        --wui-success-glass-060: rgba(38, 217, 98, 0.6);
        --wui-success-glass-080: rgba(38, 217, 98, 0.8);

        --wui-error-glass-001: rgba(242, 90, 103, 0.01);
        --wui-error-glass-002: rgba(242, 90, 103, 0.02);
        --wui-error-glass-005: rgba(242, 90, 103, 0.05);
        --wui-error-glass-010: rgba(242, 90, 103, 0.1);
        --wui-error-glass-015: rgba(242, 90, 103, 0.15);
        --wui-error-glass-020: rgba(242, 90, 103, 0.2);
        --wui-error-glass-025: rgba(242, 90, 103, 0.25);
        --wui-error-glass-030: rgba(242, 90, 103, 0.3);
        --wui-error-glass-060: rgba(242, 90, 103, 0.6);
        --wui-error-glass-080: rgba(242, 90, 103, 0.8);

        --wui-icon-box-bg-error-base-100: #3c2426;
        --wui-icon-box-bg-blue-base-100: #20303f;
        --wui-icon-box-bg-success-base-100: #1f3a28;
        --wui-icon-box-bg-inverse-base-100: #243240;

        --wui-all-wallets-bg-base-100: #222b35;

        --wui-avatar-border-base: #252525;

        --wui-thumbnail-border-base: #252525;

        --wui-gray-glass-001: rgba(255, 255, 255, 0.01);
        --wui-gray-glass-002: rgba(255, 255, 255, 0.02);
        --wui-gray-glass-005: rgba(255, 255, 255, 0.05);
        --wui-gray-glass-010: rgba(255, 255, 255, 0.1);
        --wui-gray-glass-015: rgba(255, 255, 255, 0.15);
        --wui-gray-glass-020: rgba(255, 255, 255, 0.2);
        --wui-gray-glass-025: rgba(255, 255, 255, 0.25);
        --wui-gray-glass-030: rgba(255, 255, 255, 0.3);
        --wui-gray-glass-060: rgba(255, 255, 255, 0.6);
        --wui-gray-glass-080: rgba(255, 255, 255, 0.8);
        --wui-gray-glass-090: rgba(255, 255, 255, 0.9);
      }
    `,dark:x`
      :root {
        --w3m-color-mix: ${p(ie?.["--w3m-color-mix"]||"#000")};
        --w3m-accent: ${p(ie?.["--w3m-accent"]||"#3396ff")};
        --w3m-default: #000;

        --wui-color-modal-bg-base: #fff;

        --wui-color-blue-base-100: #3396ff;

        --wui-color-accent-base-100: var(--w3m-accent);
        --wui-color-accent-base-090: #2d7dd2;
        --wui-color-accent-base-080: #2978cc;

        --wui-accent-glass-base-090: rgba(51, 150, 255, 0.9);
        --wui-accent-glass-base-080: rgba(51, 150, 255, 0.8);
        --wui-accent-glass-base-020: rgba(51, 150, 255, 0.2);
        --wui-accent-glass-base-015: rgba(51, 150, 255, 0.15);
        --wui-accent-glass-base-010: rgba(51, 150, 255, 0.1);
        --wui-accent-glass-base-005: rgba(51, 150, 255, 0.05);
        --wui-accent-glass-base-002: rgba(51, 150, 255, 0.02);

        --wui-color-fg-base-100: #141414;
        --wui-color-fg-base-125: #2d3131;
        --wui-color-fg-base-150: #474d4d;
        --wui-color-fg-base-175: #636d6d;
        --wui-color-fg-base-200: #798686;
        --wui-color-fg-base-225: #828f8f;
        --wui-color-fg-base-250: #8b9797;
        --wui-color-fg-base-275: #95a0a0;
        --wui-color-fg-base-300: #9ea9a9;

        --wui-color-bg-base-100: #ffffff;
        --wui-color-bg-base-125: #f5fafa;
        --wui-color-bg-base-150: #f3f8f8;
        --wui-color-bg-base-175: #eef4f4;
        --wui-color-bg-base-200: #eaf1f1;
        --wui-color-bg-base-225: #e5eded;
        --wui-color-bg-base-250: #e1e9e9;
        --wui-color-bg-base-275: #dce7e7;
        --wui-color-bg-base-300: #d8e3e3;

        --wui-color-success-base-100: #26b562;
        --wui-color-error-base-100: #f05142;

        --wui-success-glass-001: rgba(38, 181, 98, 0.01);
        --wui-success-glass-002: rgba(38, 181, 98, 0.02);
        --wui-success-glass-005: rgba(38, 181, 98, 0.05);
        --wui-success-glass-010: rgba(38, 181, 98, 0.1);
        --wui-success-glass-015: rgba(38, 181, 98, 0.15);
        --wui-success-glass-020: rgba(38, 181, 98, 0.2);
        --wui-success-glass-025: rgba(38, 181, 98, 0.25);
        --wui-success-glass-030: rgba(38, 181, 98, 0.3);
        --wui-success-glass-060: rgba(38, 181, 98, 0.6);
        --wui-success-glass-080: rgba(38, 181, 98, 0.8);

        --wui-error-glass-001: rgba(240, 81, 66, 0.01);
        --wui-error-glass-002: rgba(240, 81, 66, 0.02);
        --wui-error-glass-005: rgba(240, 81, 66, 0.05);
        --wui-error-glass-010: rgba(240, 81, 66, 0.1);
        --wui-error-glass-015: rgba(240, 81, 66, 0.15);
        --wui-error-glass-020: rgba(240, 81, 66, 0.2);
        --wui-error-glass-025: rgba(240, 81, 66, 0.25);
        --wui-error-glass-030: rgba(240, 81, 66, 0.3);
        --wui-error-glass-060: rgba(240, 81, 66, 0.6);
        --wui-error-glass-080: rgba(240, 81, 66, 0.8);

        --wui-icon-box-bg-error-base-100: #f4dfdd;
        --wui-icon-box-bg-blue-base-100: #d9ecfb;
        --wui-icon-box-bg-success-base-100: #daf0e4;
        --wui-icon-box-bg-inverse-base-100: #dcecfc;

        --wui-all-wallets-bg-base-100: #e8f1fa;

        --wui-avatar-border-base: #f3f4f4;

        --wui-thumbnail-border-base: #eaefef;

        --wui-gray-glass-001: rgba(0, 0, 0, 0.01);
        --wui-gray-glass-002: rgba(0, 0, 0, 0.02);
        --wui-gray-glass-005: rgba(0, 0, 0, 0.05);
        --wui-gray-glass-010: rgba(0, 0, 0, 0.1);
        --wui-gray-glass-015: rgba(0, 0, 0, 0.15);
        --wui-gray-glass-020: rgba(0, 0, 0, 0.2);
        --wui-gray-glass-025: rgba(0, 0, 0, 0.25);
        --wui-gray-glass-030: rgba(0, 0, 0, 0.3);
        --wui-gray-glass-060: rgba(0, 0, 0, 0.6);
        --wui-gray-glass-080: rgba(0, 0, 0, 0.8);
        --wui-gray-glass-090: rgba(0, 0, 0, 0.9);
      }
    `}}const Yt=x`
  *,
  *::after,
  *::before,
  :host {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-style: normal;
    text-rendering: optimizeSpeed;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    -webkit-tap-highlight-color: transparent;
    font-family: var(--wui-font-family);
    backface-visibility: hidden;
  }
`,Yn=x`
  button,
  a {
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    transition:
      background-color var(--wui-ease-inout-power-1) var(--wui-duration-md),
      color var(--wui-ease-inout-power-1) var(--wui-duration-md),
      box-shadow var(--wui-ease-inout-power-1) var(--wui-duration-md);
    will-change: background-color, color;
    outline: none;
    border: 1px solid transparent;
    column-gap: var(--wui-spacing-3xs);
    background-color: transparent;
    text-decoration: none;
  }

  @media (hover: hover) and (pointer: fine) {
    button:hover:enabled {
      background-color: var(--wui-gray-glass-005);
    }

    button:active:enabled {
      background-color: var(--wui-gray-glass-010);
    }

    button[data-variant='fill']:hover:enabled {
      background-color: var(--wui-color-accent-090);
    }

    button[data-variant='accentBg']:hover:enabled {
      background: var(--wui-accent-glass-015);
    }

    button[data-variant='accentBg']:active:enabled {
      background: var(--wui-accent-glass-020);
    }
  }

  button:disabled {
    cursor: not-allowed;
    background-color: var(--wui-gray-glass-005);
  }

  button[data-variant='shade']:disabled,
  button[data-variant='accent']:disabled,
  button[data-variant='accentBg']:disabled {
    background-color: var(--wui-gray-glass-010);
    color: var(--wui-gray-glass-015);
    filter: grayscale(1);
  }

  button:disabled > wui-wallet-image,
  button:disabled > wui-all-wallets-image,
  button:disabled > wui-network-image,
  button:disabled > wui-image,
  button:disabled > wui-icon-box,
  button:disabled > wui-transaction-visual,
  button:disabled > wui-logo {
    filter: grayscale(1);
  }

  button:focus-visible,
  a:focus-visible {
    border: 1px solid var(--wui-color-accent-100);
    background-color: var(--wui-gray-glass-005);
    -webkit-box-shadow: 0px 0px 0px 4px var(--wui-box-shadow-blue);
    -moz-box-shadow: 0px 0px 0px 4px var(--wui-box-shadow-blue);
    box-shadow: 0px 0px 0px 4px var(--wui-box-shadow-blue);
  }

  button[data-variant='fill']:focus-visible {
    background-color: var(--wui-color-accent-090);
  }

  button[data-variant='fill'] {
    color: var(--wui-color-inverse-100);
    background-color: var(--wui-color-accent-100);
  }

  button[data-variant='fill']:disabled {
    color: var(--wui-gray-glass-015);
    background-color: var(--wui-gray-glass-015);
  }

  button[data-variant='fill']:disabled > wui-icon {
    color: var(--wui-gray-glass-015);
  }

  button[data-variant='shade'] {
    color: var(--wui-color-fg-200);
  }

  button[data-variant='accent'],
  button[data-variant='accentBg'] {
    color: var(--wui-color-accent-100);
  }

  button[data-variant='accentBg'] {
    background: var(--wui-accent-glass-010);
    border: 1px solid var(--wui-accent-glass-010);
  }

  button[data-variant='fullWidth'] {
    width: 100%;
    border-radius: var(--wui-border-radius-xs);
    height: 56px;
    border: none;
    background-color: var(--wui-gray-glass-002);
    color: var(--wui-color-fg-200);
    gap: var(--wui-spacing-xs);
  }

  button:active:enabled {
    background-color: var(--wui-gray-glass-010);
  }

  button[data-variant='fill']:active:enabled {
    background-color: var(--wui-color-accent-080);
    border: 1px solid var(--wui-gray-glass-010);
  }

  input {
    border: none;
    outline: none;
    appearance: none;
  }
`,tr=x`
  .wui-color-inherit {
    color: var(--wui-color-inherit);
  }

  .wui-color-accent-100 {
    color: var(--wui-color-accent-100);
  }

  .wui-color-error-100 {
    color: var(--wui-color-error-100);
  }

  .wui-color-success-100 {
    color: var(--wui-color-success-100);
  }

  .wui-color-inverse-100 {
    color: var(--wui-color-inverse-100);
  }

  .wui-color-inverse-000 {
    color: var(--wui-color-inverse-000);
  }

  .wui-color-fg-100 {
    color: var(--wui-color-fg-100);
  }

  .wui-color-fg-200 {
    color: var(--wui-color-fg-200);
  }

  .wui-color-fg-300 {
    color: var(--wui-color-fg-300);
  }

  .wui-bg-color-inherit {
    background-color: var(--wui-color-inherit);
  }

  .wui-bg-color-blue-100 {
    background-color: var(--wui-color-accent-100);
  }

  .wui-bg-color-error-100 {
    background-color: var(--wui-color-error-100);
  }

  .wui-bg-color-success-100 {
    background-color: var(--wui-color-success-100);
  }

  .wui-bg-color-inverse-100 {
    background-color: var(--wui-color-inverse-100);
  }

  .wui-bg-color-inverse-000 {
    background-color: var(--wui-color-inverse-000);
  }

  .wui-bg-color-fg-100 {
    background-color: var(--wui-color-fg-100);
  }

  .wui-bg-color-fg-200 {
    background-color: var(--wui-color-fg-200);
  }

  .wui-bg-color-fg-300 {
    background-color: var(--wui-color-fg-300);
  }
`;function Wt(ie){return function(q){return"function"==typeof q?function v2(ie,M){return customElements.get(ie)||customElements.define(ie,M),M}(ie,q):function dr(ie,M){const{kind:q,elements:fe}=M;return{kind:q,elements:fe,finisher(xe){customElements.get(ie)||customElements.define(ie,xe)}}}(ie,q)}}const ti=x`
  :host {
    display: block;
    border-radius: clamp(0px, var(--wui-border-radius-l), 44px);
    box-shadow: 0 0 0 1px var(--wui-gray-glass-005);
    background-color: var(--wui-color-modal-bg);
    overflow: hidden;
  }
`;let Vn=class extends Be{render(){return de`<slot></slot>`}};Vn.styles=[Yt,ti],Vn=function(ie,M,q,fe){var Ie,xe=arguments.length,G=xe<3?M:null===fe?fe=Object.getOwnPropertyDescriptor(M,q):fe;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)G=Reflect.decorate(ie,M,q,fe);else for(var Ye=ie.length-1;Ye>=0;Ye--)(Ie=ie[Ye])&&(G=(xe<3?Ie(G):xe>3?Ie(M,q,G):Ie(M,q))||G);return xe>3&&G&&Object.defineProperty(M,q,G),G}([Wt("wui-card")],Vn);const ln={attribute:!0,type:String,converter:Me,reflect:!1,hasChanged:he},H1=(ie=ln,M,q)=>{const{kind:fe,metadata:xe}=q;let G=globalThis.litPropertyMetadata.get(xe);if(void 0===G&&globalThis.litPropertyMetadata.set(xe,G=new Map),G.set(q.name,ie),"accessor"===fe){const{name:Ie}=q;return{set(Ye){const nn=M.get.call(this);M.set.call(this,Ye),this.requestUpdate(Ie,nn,ie)},init(Ye){return void 0!==Ye&&this.P(Ie,void 0,ie),Ye}}}if("setter"===fe){const{name:Ie}=q;return function(Ye){const nn=this[Ie];M.call(this,Ye),this.requestUpdate(Ie,nn,ie)}}throw Error("Unsupported decorator location: "+fe)};function Qe(ie){return(M,q)=>"object"==typeof q?H1(ie,M,q):((fe,xe,G)=>{const Ie=xe.hasOwnProperty(G);return xe.constructor.createProperty(G,Ie?{...fe,wrapped:!0}:fe),Ie?Object.getOwnPropertyDescriptor(xe,G):void 0})(ie,M,q)}function vi(ie){return Qe({...ie,state:!0,attribute:!1})}const r1=x`
  :host {
    display: flex;
    aspect-ratio: 1 / 1;
    color: var(--local-color);
    width: var(--local-width);
  }

  svg {
    width: inherit;
    height: inherit;
    object-fit: contain;
    object-position: center;
  }
`,gr=ke`<svg fill="none" viewBox="0 0 24 24">
  <path
    style="fill: var(--wui-color-accent-100);"
    d="M10.2 6.6a3.6 3.6 0 1 1-7.2 0 3.6 3.6 0 0 1 7.2 0ZM21 6.6a3.6 3.6 0 1 1-7.2 0 3.6 3.6 0 0 1 7.2 0ZM10.2 17.4a3.6 3.6 0 1 1-7.2 0 3.6 3.6 0 0 1 7.2 0ZM21 17.4a3.6 3.6 0 1 1-7.2 0 3.6 3.6 0 0 1 7.2 0Z"
  />
</svg>`,An=ke`<svg
  fill="none"
  viewBox="0 0 21 20"
>
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M10.5 2.42908C6.31875 2.42908 2.92859 5.81989 2.92859 10.0034C2.92859 14.1869 6.31875 17.5777 10.5 17.5777C14.6813 17.5777 18.0714 14.1869 18.0714 10.0034C18.0714 5.81989 14.6813 2.42908 10.5 2.42908ZM0.928589 10.0034C0.928589 4.71596 5.21355 0.429077 10.5 0.429077C15.7865 0.429077 20.0714 4.71596 20.0714 10.0034C20.0714 15.2908 15.7865 19.5777 10.5 19.5777C5.21355 19.5777 0.928589 15.2908 0.928589 10.0034ZM10.5 5.75003C11.0523 5.75003 11.5 6.19774 11.5 6.75003L11.5 10.8343L12.7929 9.54137C13.1834 9.15085 13.8166 9.15085 14.2071 9.54137C14.5976 9.9319 14.5976 10.5651 14.2071 10.9556L11.2071 13.9556C10.8166 14.3461 10.1834 14.3461 9.79291 13.9556L6.79291 10.9556C6.40239 10.5651 6.40239 9.9319 6.79291 9.54137C7.18343 9.15085 7.8166 9.15085 8.20712 9.54137L9.50002 10.8343L9.50002 6.75003C9.50002 6.19774 9.94773 5.75003 10.5 5.75003Z"
    clip-rule="evenodd"
  /></svg
>`,yo=ke`
<svg width="36" height="36">
  <path
    d="M28.724 0H7.271A7.269 7.269 0 0 0 0 7.272v21.46A7.268 7.268 0 0 0 7.271 36H28.73A7.272 7.272 0 0 0 36 28.728V7.272A7.275 7.275 0 0 0 28.724 0Z"
    fill="url(#a)"
  />
  <path
    d="m17.845 8.271.729-1.26a1.64 1.64 0 1 1 2.843 1.638l-7.023 12.159h5.08c1.646 0 2.569 1.935 1.853 3.276H6.434a1.632 1.632 0 0 1-1.638-1.638c0-.909.73-1.638 1.638-1.638h4.176l5.345-9.265-1.67-2.898a1.642 1.642 0 0 1 2.844-1.638l.716 1.264Zm-6.317 17.5-1.575 2.732a1.64 1.64 0 1 1-2.844-1.638l1.17-2.025c1.323-.41 2.398-.095 3.249.931Zm13.56-4.954h4.262c.909 0 1.638.729 1.638 1.638 0 .909-.73 1.638-1.638 1.638h-2.367l1.597 2.772c.45.788.185 1.782-.602 2.241a1.642 1.642 0 0 1-2.241-.603c-2.69-4.666-4.711-8.159-6.052-10.485-1.372-2.367-.391-4.743.576-5.549 1.075 1.846 2.682 4.631 4.828 8.348Z"
    fill="#fff"
  />
  <defs>
    <linearGradient id="a" x1="18" y1="0" x2="18" y2="36" gradientUnits="userSpaceOnUse">
      <stop stop-color="#18BFFB" />
      <stop offset="1" stop-color="#2072F3" />
    </linearGradient>
  </defs>
</svg>`,ni=ke`<svg fill="none" viewBox="0 0 40 40">
  <g clip-path="url(#a)">
    <g clip-path="url(#b)">
      <circle cx="20" cy="19.89" r="20" fill="#000" />
      <g clip-path="url(#c)">
        <path
          fill="#fff"
          d="M28.77 23.3c-.69 1.99-2.75 5.52-4.87 5.56-1.4.03-1.86-.84-3.46-.84-1.61 0-2.12.81-3.45.86-2.25.1-5.72-5.1-5.72-9.62 0-4.15 2.9-6.2 5.42-6.25 1.36-.02 2.64.92 3.47.92.83 0 2.38-1.13 4.02-.97.68.03 2.6.28 3.84 2.08-3.27 2.14-2.76 6.61.75 8.25ZM24.2 7.88c-2.47.1-4.49 2.69-4.2 4.84 2.28.17 4.47-2.39 4.2-4.84Z"
        />
      </g>
    </g>
  </g>
  <defs>
    <clipPath id="a"><rect width="40" height="40" fill="#fff" rx="20" /></clipPath>
    <clipPath id="b"><path fill="#fff" d="M0 0h40v40H0z" /></clipPath>
    <clipPath id="c"><path fill="#fff" d="M8 7.89h24v24H8z" /></clipPath>
  </defs>
</svg>`,nr=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M7 1.99a1 1 0 0 1 1 1v7.58l2.46-2.46a1 1 0 0 1 1.41 1.42L7.7 13.69a1 1 0 0 1-1.41 0L2.12 9.53A1 1 0 0 1 3.54 8.1L6 10.57V3a1 1 0 0 1 1-1Z"
    clip-rule="evenodd"
  />
</svg>`,y2=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M13 7.99a1 1 0 0 1-1 1H4.4l2.46 2.46a1 1 0 1 1-1.41 1.41L1.29 8.7a1 1 0 0 1 0-1.41L5.46 3.1a1 1 0 0 1 1.41 1.42L4.41 6.99H12a1 1 0 0 1 1 1Z"
    clip-rule="evenodd"
  />
</svg>`,_n=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M1 7.99a1 1 0 0 1 1-1h7.58L7.12 4.53A1 1 0 1 1 8.54 3.1l4.16 4.17a1 1 0 0 1 0 1.41l-4.16 4.17a1 1 0 1 1-1.42-1.41l2.46-2.46H2a1 1 0 0 1-1-1Z"
    clip-rule="evenodd"
  />
</svg>`,fn=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M7 13.99a1 1 0 0 1-1-1V5.4L3.54 7.86a1 1 0 0 1-1.42-1.41L6.3 2.28a1 1 0 0 1 1.41 0l4.17 4.17a1 1 0 1 1-1.41 1.41L8 5.4v7.59a1 1 0 0 1-1 1Z"
    clip-rule="evenodd"
  />
</svg>`,_o=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M4 6.4a1 1 0 0 1-.46.89 6.98 6.98 0 0 0 .38 6.18A7 7 0 0 0 16.46 7.3a1 1 0 0 1-.47-.92 7 7 0 0 0-12 .03Zm-2.02-.5a9 9 0 1 1 16.03 8.2A9 9 0 0 1 1.98 5.9Z"
    clip-rule="evenodd"
  />
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M6.03 8.63c-1.46-.3-2.72-.75-3.6-1.35l-.02-.01-.14-.11a1 1 0 0 1 1.2-1.6l.1.08c.6.4 1.52.74 2.69 1 .16-.99.39-1.88.67-2.65.3-.79.68-1.5 1.15-2.02A2.58 2.58 0 0 1 9.99 1c.8 0 1.45.44 1.92.97.47.52.84 1.23 1.14 2.02.29.77.52 1.66.68 2.64a8 8 0 0 0 2.7-1l.26-.18h.48a1 1 0 0 1 .12 2c-.86.51-2.01.91-3.34 1.18a22.24 22.24 0 0 1-.03 3.19c1.45.29 2.7.73 3.58 1.31a1 1 0 0 1-1.1 1.68c-.6-.4-1.56-.76-2.75-1-.15.8-.36 1.55-.6 2.2-.3.79-.67 1.5-1.14 2.02-.47.53-1.12.97-1.92.97-.8 0-1.45-.44-1.91-.97a6.51 6.51 0 0 1-1.15-2.02c-.24-.65-.44-1.4-.6-2.2-1.18.24-2.13.6-2.73.99a1 1 0 1 1-1.1-1.67c.88-.58 2.12-1.03 3.57-1.31a22.03 22.03 0 0 1-.04-3.2Zm2.2-1.7c.15-.86.34-1.61.58-2.24.24-.65.51-1.12.76-1.4.25-.28.4-.29.42-.29.03 0 .17.01.42.3.25.27.52.74.77 1.4.23.62.43 1.37.57 2.22a19.96 19.96 0 0 1-3.52 0Zm-.18 4.6a20.1 20.1 0 0 1-.03-2.62 21.95 21.95 0 0 0 3.94 0 20.4 20.4 0 0 1-.03 2.63 21.97 21.97 0 0 0-3.88 0Zm.27 2c.13.66.3 1.26.49 1.78.24.65.51 1.12.76 1.4.25.28.4.29.42.29.03 0 .17-.01.42-.3.25-.27.52-.74.77-1.4.19-.5.36-1.1.49-1.78a20.03 20.03 0 0 0-3.35 0Z"
    clip-rule="evenodd"
  />
</svg>`,bo=ke`<svg
  xmlns="http://www.w3.org/2000/svg"
  width="12"
  height="12"
  viewBox="0 0 12 12"
  fill="none"
>
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M10.537 2.34245C10.8997 2.64654 10.9471 3.187 10.6429 3.54959L5.61072 9.54757C5.45645 9.73144 5.23212 9.84222 4.99229 9.85295C4.75247 9.86368 4.51914 9.77337 4.34906 9.60401L1.40881 6.6761C1.07343 6.34213 1.07238 5.7996 1.40647 5.46433C1.74055 5.12906 2.28326 5.12801 2.61865 5.46198L4.89731 7.73108L9.32942 2.44834C9.63362 2.08576 10.1743 2.03835 10.537 2.34245Z"
    fill="currentColor"
  /></svg
>`,_2=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M1.46 4.96a1 1 0 0 1 1.41 0L8 10.09l5.13-5.13a1 1 0 1 1 1.41 1.41l-5.83 5.84a1 1 0 0 1-1.42 0L1.46 6.37a1 1 0 0 1 0-1.41Z"
    clip-rule="evenodd"
  />
</svg>`,s1=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M11.04 1.46a1 1 0 0 1 0 1.41L5.91 8l5.13 5.13a1 1 0 1 1-1.41 1.41L3.79 8.71a1 1 0 0 1 0-1.42l5.84-5.83a1 1 0 0 1 1.41 0Z"
    clip-rule="evenodd"
  />
</svg>`,kt=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M4.96 14.54a1 1 0 0 1 0-1.41L10.09 8 4.96 2.87a1 1 0 0 1 1.41-1.41l5.84 5.83a1 1 0 0 1 0 1.42l-5.84 5.83a1 1 0 0 1-1.41 0Z"
    clip-rule="evenodd"
  />
</svg>`,Wa=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M14.54 11.04a1 1 0 0 1-1.41 0L8 5.92l-5.13 5.12a1 1 0 1 1-1.41-1.41l5.83-5.84a1 1 0 0 1 1.42 0l5.83 5.84a1 1 0 0 1 0 1.41Z"
    clip-rule="evenodd"
  />
</svg>`,Bn=ke`<svg width="36" height="36" fill="none">
  <path
    fill="#fff"
    fill-opacity=".05"
    d="M0 14.94c0-5.55 0-8.326 1.182-10.4a9 9 0 0 1 3.359-3.358C6.614 0 9.389 0 14.94 0h6.12c5.55 0 8.326 0 10.4 1.182a9 9 0 0 1 3.358 3.359C36 6.614 36 9.389 36 14.94v6.12c0 5.55 0 8.326-1.182 10.4a9 9 0 0 1-3.359 3.358C29.386 36 26.611 36 21.06 36h-6.12c-5.55 0-8.326 0-10.4-1.182a9 9 0 0 1-3.358-3.359C0 29.386 0 26.611 0 21.06v-6.12Z"
  />
  <path
    stroke="#fff"
    stroke-opacity=".05"
    d="M14.94.5h6.12c2.785 0 4.84 0 6.46.146 1.612.144 2.743.43 3.691.97a8.5 8.5 0 0 1 3.172 3.173c.541.948.826 2.08.971 3.692.145 1.62.146 3.675.146 6.459v6.12c0 2.785 0 4.84-.146 6.46-.145 1.612-.43 2.743-.97 3.691a8.5 8.5 0 0 1-3.173 3.172c-.948.541-2.08.826-3.692.971-1.62.145-3.674.146-6.459.146h-6.12c-2.784 0-4.84 0-6.46-.146-1.612-.145-2.743-.43-3.691-.97a8.5 8.5 0 0 1-3.172-3.173c-.541-.948-.827-2.08-.971-3.692C.5 25.9.5 23.845.5 21.06v-6.12c0-2.784 0-4.84.146-6.46.144-1.612.43-2.743.97-3.691A8.5 8.5 0 0 1 4.79 1.617C5.737 1.076 6.869.79 8.48.646 10.1.5 12.156.5 14.94.5Z"
  />
  <path
    fill="url(#a)"
    d="M17.998 10.8h12.469a14.397 14.397 0 0 0-24.938.001l6.234 10.798.006-.001a7.19 7.19 0 0 1 6.23-10.799Z"
  />
  <path
    fill="url(#b)"
    d="m24.237 21.598-6.234 10.798A14.397 14.397 0 0 0 30.47 10.798H18.002l-.002.006a7.191 7.191 0 0 1 6.237 10.794Z"
  />
  <path
    fill="url(#c)"
    d="M11.765 21.601 5.531 10.803A14.396 14.396 0 0 0 18.001 32.4l6.235-10.798-.004-.004a7.19 7.19 0 0 1-12.466.004Z"
  />
  <path fill="#fff" d="M18 25.2a7.2 7.2 0 1 0 0-14.4 7.2 7.2 0 0 0 0 14.4Z" />
  <path fill="#1A73E8" d="M18 23.7a5.7 5.7 0 1 0 0-11.4 5.7 5.7 0 0 0 0 11.4Z" />
  <defs>
    <linearGradient
      id="a"
      x1="6.294"
      x2="41.1"
      y1="5.995"
      y2="5.995"
      gradientUnits="userSpaceOnUse"
    >
      <stop stop-color="#D93025" />
      <stop offset="1" stop-color="#EA4335" />
    </linearGradient>
    <linearGradient
      id="b"
      x1="20.953"
      x2="37.194"
      y1="32.143"
      y2="2.701"
      gradientUnits="userSpaceOnUse"
    >
      <stop stop-color="#FCC934" />
      <stop offset="1" stop-color="#FBBC04" />
    </linearGradient>
    <linearGradient
      id="c"
      x1="25.873"
      x2="9.632"
      y1="31.2"
      y2="1.759"
      gradientUnits="userSpaceOnUse"
    >
      <stop stop-color="#1E8E3E" />
      <stop offset="1" stop-color="#34A853" />
    </linearGradient>
  </defs>
</svg>`,Ni=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M7 2.99a5 5 0 1 0 0 10 5 5 0 0 0 0-10Zm-7 5a7 7 0 1 1 14 0 7 7 0 0 1-14 0Zm7-4a1 1 0 0 1 1 1v2.58l1.85 1.85a1 1 0 0 1-1.41 1.42L6.29 8.69A1 1 0 0 1 6 8v-3a1 1 0 0 1 1-1Z"
    clip-rule="evenodd"
  />
</svg>`,O0=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M2.54 2.54a1 1 0 0 1 1.42 0L8 6.6l4.04-4.05a1 1 0 1 1 1.42 1.42L9.4 8l4.05 4.04a1 1 0 0 1-1.42 1.42L8 9.4l-4.04 4.05a1 1 0 0 1-1.42-1.42L6.6 8 2.54 3.96a1 1 0 0 1 0-1.42Z"
    clip-rule="evenodd"
  />
</svg>`,Hu=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M10 3a7 7 0 0 0-6.85 8.44l8.29-8.3C10.97 3.06 10.49 3 10 3Zm3.49.93-9.56 9.56c.32.55.71 1.06 1.16 1.5L15 5.1a7.03 7.03 0 0 0-1.5-1.16Zm2.7 2.8-9.46 9.46a7 7 0 0 0 9.46-9.46ZM1.99 5.9A9 9 0 1 1 18 14.09 9 9 0 0 1 1.98 5.91Z"
    clip-rule="evenodd"
  />
</svg>`,H0=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M8 2a6 6 0 1 0 0 12A6 6 0 0 0 8 2ZM0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm10.66-2.65a1 1 0 0 1 .23 1.06L9.83 9.24a1 1 0 0 1-.59.58l-2.83 1.06A1 1 0 0 1 5.13 9.6l1.06-2.82a1 1 0 0 1 .58-.59L9.6 5.12a1 1 0 0 1 1.06.23ZM7.9 7.89l-.13.35.35-.13.12-.35-.34.13Z"
    clip-rule="evenodd"
  />
</svg>`,Zc=ke`<svg
  xmlns="http://www.w3.org/2000/svg"
  width="16"
  height="16"
  viewBox="0 0 16 16"
  fill="none"
>
  <path
    fill="currentColor"
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M9.21498 1.28565H10.5944C11.1458 1.28562 11.6246 1.2856 12.0182 1.32093C12.4353 1.35836 12.853 1.44155 13.2486 1.66724C13.7005 1.92498 14.0749 2.29935 14.3326 2.75122C14.5583 3.14689 14.6415 3.56456 14.6789 3.9817C14.7143 4.37531 14.7142 4.85403 14.7142 5.40545V6.78489C14.7142 7.33631 14.7143 7.81503 14.6789 8.20865C14.6415 8.62578 14.5583 9.04345 14.3326 9.43912C14.0749 9.89099 13.7005 10.2654 13.2486 10.5231C12.853 10.7488 12.4353 10.832 12.0182 10.8694C11.7003 10.8979 11.3269 10.9034 10.9045 10.9045C10.9034 11.3269 10.8979 11.7003 10.8694 12.0182C10.832 12.4353 10.7488 12.853 10.5231 13.2486C10.2654 13.7005 9.89099 14.0749 9.43912 14.3326C9.04345 14.5583 8.62578 14.6415 8.20865 14.6789C7.81503 14.7143 7.33631 14.7142 6.78489 14.7142H5.40545C4.85403 14.7142 4.37531 14.7143 3.9817 14.6789C3.56456 14.6415 3.14689 14.5583 2.75122 14.3326C2.29935 14.0749 1.92498 13.7005 1.66724 13.2486C1.44155 12.853 1.35836 12.4353 1.32093 12.0182C1.2856 11.6246 1.28562 11.1458 1.28565 10.5944V9.21498C1.28562 8.66356 1.2856 8.18484 1.32093 7.79122C1.35836 7.37409 1.44155 6.95642 1.66724 6.56074C1.92498 6.10887 2.29935 5.73451 2.75122 5.47677C3.14689 5.25108 3.56456 5.16789 3.9817 5.13045C4.2996 5.10192 4.67301 5.09645 5.09541 5.09541C5.09645 4.67302 5.10192 4.2996 5.13045 3.9817C5.16789 3.56456 5.25108 3.14689 5.47676 2.75122C5.73451 2.29935 6.10887 1.92498 6.56074 1.66724C6.95642 1.44155 7.37409 1.35836 7.79122 1.32093C8.18484 1.2856 8.66356 1.28562 9.21498 1.28565ZM5.09541 7.09552C4.68397 7.09667 4.39263 7.10161 4.16046 7.12245C3.88053 7.14757 3.78516 7.18949 3.74214 7.21403C3.60139 7.29431 3.48478 7.41091 3.4045 7.55166C3.37997 7.59468 3.33804 7.69005 3.31292 7.96999C3.28659 8.26345 3.28565 8.65147 3.28565 9.25708V10.5523C3.28565 11.1579 3.28659 11.5459 3.31292 11.8394C3.33804 12.1193 3.37997 12.2147 3.4045 12.2577C3.48478 12.3985 3.60139 12.5151 3.74214 12.5954C3.78516 12.6199 3.88053 12.6618 4.16046 12.6869C4.45393 12.7133 4.84195 12.7142 5.44755 12.7142H6.74279C7.3484 12.7142 7.73641 12.7133 8.02988 12.6869C8.30981 12.6618 8.40518 12.6199 8.44821 12.5954C8.58895 12.5151 8.70556 12.3985 8.78584 12.2577C8.81038 12.2147 8.8523 12.1193 8.87742 11.8394C8.89825 11.6072 8.90319 11.3159 8.90435 10.9045C8.48219 10.9034 8.10898 10.8979 7.79122 10.8694C7.37409 10.832 6.95641 10.7488 6.56074 10.5231C6.10887 10.2654 5.73451 9.89099 5.47676 9.43912C5.25108 9.04345 5.16789 8.62578 5.13045 8.20865C5.10194 7.89089 5.09645 7.51767 5.09541 7.09552ZM7.96999 3.31292C7.69005 3.33804 7.59468 3.37997 7.55166 3.4045C7.41091 3.48478 7.29431 3.60139 7.21403 3.74214C7.18949 3.78516 7.14757 3.88053 7.12245 4.16046C7.09611 4.45393 7.09517 4.84195 7.09517 5.44755V6.74279C7.09517 7.3484 7.09611 7.73641 7.12245 8.02988C7.14757 8.30981 7.18949 8.40518 7.21403 8.4482C7.29431 8.58895 7.41091 8.70556 7.55166 8.78584C7.59468 8.81038 7.69005 8.8523 7.96999 8.87742C8.26345 8.90376 8.65147 8.9047 9.25708 8.9047H10.5523C11.1579 8.9047 11.5459 8.90376 11.8394 8.87742C12.1193 8.8523 12.2147 8.81038 12.2577 8.78584C12.3985 8.70556 12.5151 8.58895 12.5954 8.4482C12.6199 8.40518 12.6618 8.30981 12.6869 8.02988C12.7133 7.73641 12.7142 7.3484 12.7142 6.74279V5.44755C12.7142 4.84195 12.7133 4.45393 12.6869 4.16046C12.6618 3.88053 12.6199 3.78516 12.5954 3.74214C12.5151 3.60139 12.3985 3.48478 12.2577 3.4045C12.2147 3.37997 12.1193 3.33804 11.8394 3.31292C11.5459 3.28659 11.1579 3.28565 10.5523 3.28565H9.25708C8.65147 3.28565 8.26345 3.28659 7.96999 3.31292Z"
    fill="#788181"
  /></svg
>`,Ls=ke`<svg
  width="14"
  height="14"
  viewBox="0 0 14 14"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
>
  <path
    fill="currentColor"
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M7.0023 0.875C7.48571 0.875 7.8776 1.26675 7.8776 1.75V6.125H12.2541C12.7375 6.125 13.1294 6.51675 13.1294 7C13.1294 7.48325 12.7375 7.875 12.2541 7.875H7.8776V12.25C7.8776 12.7332 7.48571 13.125 7.0023 13.125C6.51889 13.125 6.12701 12.7332 6.12701 12.25V7.875H1.75054C1.26713 7.875 0.875244 7.48325 0.875244 7C0.875244 6.51675 1.26713 6.125 1.75054 6.125H6.12701V1.75C6.12701 1.26675 6.51889 0.875 7.0023 0.875Z"
    fill="#47A1FF"
  /></svg
>`,Vu=ke` <svg fill="none" viewBox="0 0 13 4">
  <path fill="currentColor" d="M.5 0h12L8.9 3.13a3.76 3.76 0 0 1-4.8 0L.5 0Z" />
</svg>`,V0=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M13.66 2H6.34c-1.07 0-1.96 0-2.68.08-.74.08-1.42.25-2.01.68a4 4 0 0 0-.89.89c-.43.6-.6 1.27-.68 2.01C0 6.38 0 7.26 0 8.34v.89c0 1.07 0 1.96.08 2.68.08.74.25 1.42.68 2.01a4 4 0 0 0 .89.89c.6.43 1.27.6 2.01.68a27 27 0 0 0 2.68.08h7.32a27 27 0 0 0 2.68-.08 4.03 4.03 0 0 0 2.01-.68 4 4 0 0 0 .89-.89c.43-.6.6-1.27.68-2.01.08-.72.08-1.6.08-2.68v-.89c0-1.07 0-1.96-.08-2.68a4.04 4.04 0 0 0-.68-2.01 4 4 0 0 0-.89-.89c-.6-.43-1.27-.6-2.01-.68C15.62 2 14.74 2 13.66 2ZM2.82 4.38c.2-.14.48-.25 1.06-.31C4.48 4 5.25 4 6.4 4h7.2c1.15 0 1.93 0 2.52.07.58.06.86.17 1.06.31a2 2 0 0 1 .44.44c.14.2.25.48.31 1.06.07.6.07 1.37.07 2.52v.77c0 1.15 0 1.93-.07 2.52-.06.58-.17.86-.31 1.06a2 2 0 0 1-.44.44c-.2.14-.48.25-1.06.32-.6.06-1.37.06-2.52.06H6.4c-1.15 0-1.93 0-2.52-.06-.58-.07-.86-.18-1.06-.32a2 2 0 0 1-.44-.44c-.14-.2-.25-.48-.31-1.06C2 11.1 2 10.32 2 9.17V8.4c0-1.15 0-1.93.07-2.52.06-.58.17-.86.31-1.06a2 2 0 0 1 .44-.44Z"
    clip-rule="evenodd"
  />
  <path fill="currentColor" d="M6.14 17.57a1 1 0 1 0 0 2h7.72a1 1 0 1 0 0-2H6.14Z" />
</svg>`,Fu=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M6.07 1h.57a1 1 0 0 1 0 2h-.52c-.98 0-1.64 0-2.14.06-.48.05-.7.14-.84.24-.13.1-.25.22-.34.35-.1.14-.2.35-.25.83-.05.5-.05 1.16-.05 2.15v2.74c0 .99 0 1.65.05 2.15.05.48.14.7.25.83.1.14.2.25.34.35.14.1.36.2.84.25.5.05 1.16.05 2.14.05h.52a1 1 0 0 1 0 2h-.57c-.92 0-1.69 0-2.3-.07a3.6 3.6 0 0 1-1.8-.61c-.3-.22-.57-.49-.8-.8a3.6 3.6 0 0 1-.6-1.79C.5 11.11.5 10.35.5 9.43V6.58c0-.92 0-1.7.06-2.31a3.6 3.6 0 0 1 .62-1.8c.22-.3.48-.57.79-.79a3.6 3.6 0 0 1 1.8-.61C4.37 1 5.14 1 6.06 1ZM9.5 3a1 1 0 0 1 1.42 0l4.28 4.3a1 1 0 0 1 0 1.4L10.93 13a1 1 0 0 1-1.42-1.42L12.1 9H6.8a1 1 0 1 1 0-2h5.3L9.51 4.42a1 1 0 0 1 0-1.41Z"
    clip-rule="evenodd"
  />
</svg>`,a1=ke`<svg fill="none" viewBox="0 0 40 40">
  <g clip-path="url(#a)">
    <g clip-path="url(#b)">
      <circle cx="20" cy="19.89" r="20" fill="#5865F2" />
      <path
        fill="#fff"
        fill-rule="evenodd"
        d="M25.71 28.15C30.25 28 32 25.02 32 25.02c0-6.61-2.96-11.98-2.96-11.98-2.96-2.22-5.77-2.15-5.77-2.15l-.29.32c3.5 1.07 5.12 2.61 5.12 2.61a16.75 16.75 0 0 0-10.34-1.93l-.35.04a15.43 15.43 0 0 0-5.88 1.9s1.71-1.63 5.4-2.7l-.2-.24s-2.81-.07-5.77 2.15c0 0-2.96 5.37-2.96 11.98 0 0 1.73 2.98 6.27 3.13l1.37-1.7c-2.6-.79-3.6-2.43-3.6-2.43l.58.35.09.06.08.04.02.01.08.05a17.25 17.25 0 0 0 4.52 1.58 14.4 14.4 0 0 0 8.3-.86c.72-.27 1.52-.66 2.37-1.21 0 0-1.03 1.68-3.72 2.44.61.78 1.35 1.67 1.35 1.67Zm-9.55-9.6c-1.17 0-2.1 1.03-2.1 2.28 0 1.25.95 2.28 2.1 2.28 1.17 0 2.1-1.03 2.1-2.28.01-1.25-.93-2.28-2.1-2.28Zm7.5 0c-1.17 0-2.1 1.03-2.1 2.28 0 1.25.95 2.28 2.1 2.28 1.17 0 2.1-1.03 2.1-2.28 0-1.25-.93-2.28-2.1-2.28Z"
        clip-rule="evenodd"
      />
    </g>
  </g>
  <defs>
    <clipPath id="a"><rect width="40" height="40" fill="#fff" rx="20" /></clipPath>
    <clipPath id="b"><path fill="#fff" d="M0 0h40v40H0z" /></clipPath>
  </defs>
</svg>`,Bu=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    d="M4.25 7a.63.63 0 0 0-.63.63v3.97c0 .28-.2.51-.47.54l-.75.07a.93.93 0 0 1-.9-.47A7.51 7.51 0 0 1 5.54.92a7.5 7.5 0 0 1 9.54 4.62c.12.35.06.72-.16 1-.74.97-1.68 1.78-2.6 2.44V4.44a.64.64 0 0 0-.63-.64h-1.06c-.35 0-.63.3-.63.64v5.5c0 .23-.12.42-.32.5l-.52.23V6.05c0-.36-.3-.64-.64-.64H7.45c-.35 0-.64.3-.64.64v4.97c0 .25-.17.46-.4.52a5.8 5.8 0 0 0-.45.11v-4c0-.36-.3-.65-.64-.65H4.25ZM14.07 12.4A7.49 7.49 0 0 1 3.6 14.08c4.09-.58 9.14-2.5 11.87-6.6v.03a7.56 7.56 0 0 1-1.41 4.91Z"
  />
</svg>`,Uu=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M6.71 2.99a.57.57 0 0 0-.57.57 1 1 0 0 1-1 1c-.58 0-.96 0-1.24.03-.27.03-.37.07-.42.1a.97.97 0 0 0-.36.35c-.04.08-.09.21-.11.67a2.57 2.57 0 0 1 0 5.13c.02.45.07.6.11.66.09.15.21.28.36.36.07.04.21.1.67.12a2.57 2.57 0 0 1 5.12 0c.46-.03.6-.08.67-.12a.97.97 0 0 0 .36-.36c.03-.04.07-.14.1-.41.02-.29.03-.66.03-1.24a1 1 0 0 1 1-1 .57.57 0 0 0 0-1.15 1 1 0 0 1-1-1c0-.58 0-.95-.03-1.24a1.04 1.04 0 0 0-.1-.42.97.97 0 0 0-.36-.36 1.04 1.04 0 0 0-.42-.1c-.28-.02-.65-.02-1.24-.02a1 1 0 0 1-1-1 .57.57 0 0 0-.57-.57ZM5.15 13.98a1 1 0 0 0 .99-1v-.78a.57.57 0 0 1 1.14 0v.78a1 1 0 0 0 .99 1H8.36a66.26 66.26 0 0 0 .73 0 3.78 3.78 0 0 0 1.84-.38c.46-.26.85-.64 1.1-1.1.23-.4.32-.8.36-1.22.02-.2.03-.4.03-.63a2.57 2.57 0 0 0 0-4.75c0-.23-.01-.44-.03-.63a2.96 2.96 0 0 0-.35-1.22 2.97 2.97 0 0 0-1.1-1.1c-.4-.22-.8-.31-1.22-.35a8.7 8.7 0 0 0-.64-.04 2.57 2.57 0 0 0-4.74 0c-.23 0-.44.02-.63.04-.42.04-.83.13-1.22.35-.46.26-.84.64-1.1 1.1-.33.57-.37 1.2-.39 1.84a21.39 21.39 0 0 0 0 .72v.1a1 1 0 0 0 1 .99h.78a.57.57 0 0 1 0 1.15h-.77a1 1 0 0 0-1 .98v.1a63.87 63.87 0 0 0 0 .73c0 .64.05 1.27.38 1.83.26.47.64.85 1.1 1.11.56.32 1.2.37 1.84.38a20.93 20.93 0 0 0 .72 0h.1Z"
    clip-rule="evenodd"
  />
</svg>`,VR=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M3.74 3.99a1 1 0 0 1 1-1H11a1 1 0 0 1 1 1v6.26a1 1 0 0 1-2 0V6.4l-6.3 6.3a1 1 0 0 1-1.4-1.42l6.29-6.3H4.74a1 1 0 0 1-1-1Z"
    clip-rule="evenodd"
  />
</svg>`,FR=ke`<svg fill="none" viewBox="0 0 40 40">
  <g clip-path="url(#a)">
    <g clip-path="url(#b)">
      <circle cx="20" cy="19.89" r="20" fill="#1877F2" />
      <g clip-path="url(#c)">
        <path
          fill="#fff"
          d="M26 12.38h-2.89c-.92 0-1.61.38-1.61 1.34v1.66H26l-.36 4.5H21.5v12H17v-12h-3v-4.5h3V12.5c0-3.03 1.6-4.62 5.2-4.62H26v4.5Z"
        />
      </g>
    </g>
    <path
      fill="#1877F2"
      d="M40 20a20 20 0 1 0-23.13 19.76V25.78H11.8V20h5.07v-4.4c0-5.02 3-7.79 7.56-7.79 2.19 0 4.48.4 4.48.4v4.91h-2.53c-2.48 0-3.25 1.55-3.25 3.13V20h5.54l-.88 5.78h-4.66v13.98A20 20 0 0 0 40 20Z"
    />
    <path
      fill="#fff"
      d="m27.79 25.78.88-5.78h-5.55v-3.75c0-1.58.78-3.13 3.26-3.13h2.53V8.2s-2.3-.39-4.48-.39c-4.57 0-7.55 2.77-7.55 7.78V20H11.8v5.78h5.07v13.98a20.15 20.15 0 0 0 6.25 0V25.78h4.67Z"
    />
  </g>
  <defs>
    <clipPath id="a"><rect width="40" height="40" fill="#fff" rx="20" /></clipPath>
    <clipPath id="b"><path fill="#fff" d="M0 0h40v40H0z" /></clipPath>
    <clipPath id="c"><path fill="#fff" d="M8 7.89h24v24H8z" /></clipPath>
  </defs>
</svg>`,sw=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M0 3a1 1 0 0 1 1-1h14a1 1 0 1 1 0 2H1a1 1 0 0 1-1-1Zm2.63 5.25a1 1 0 0 1 1-1h8.75a1 1 0 1 1 0 2H3.63a1 1 0 0 1-1-1Zm2.62 5.25a1 1 0 0 1 1-1h3.5a1 1 0 0 1 0 2h-3.5a1 1 0 0 1-1-1Z"
    clip-rule="evenodd"
  />
</svg>`,BR=ke`<svg fill="none" viewBox="0 0 40 40">
  <g clip-path="url(#a)">
    <g clip-path="url(#b)">
      <circle cx="20" cy="19.89" r="20" fill="#1B1F23" />
      <g clip-path="url(#c)">
        <path
          fill="#fff"
          d="M8 19.89a12 12 0 1 1 15.8 11.38c-.6.12-.8-.26-.8-.57v-3.3c0-1.12-.4-1.85-.82-2.22 2.67-.3 5.48-1.31 5.48-5.92 0-1.31-.47-2.38-1.24-3.22.13-.3.54-1.52-.12-3.18 0 0-1-.32-3.3 1.23a11.54 11.54 0 0 0-6 0c-2.3-1.55-3.3-1.23-3.3-1.23a4.32 4.32 0 0 0-.12 3.18 4.64 4.64 0 0 0-1.24 3.22c0 4.6 2.8 5.63 5.47 5.93-.34.3-.65.83-.76 1.6-.69.31-2.42.84-3.5-1 0 0-.63-1.15-1.83-1.23 0 0-1.18-.02-.09.73 0 0 .8.37 1.34 1.76 0 0 .7 2.14 4.03 1.41v2.24c0 .31-.2.68-.8.57A12 12 0 0 1 8 19.9Z"
        />
      </g>
    </g>
  </g>
  <defs>
    <clipPath id="a"><rect width="40" height="40" fill="#fff" rx="20" /></clipPath>
    <clipPath id="b"><path fill="#fff" d="M0 0h40v40H0z" /></clipPath>
    <clipPath id="c"><path fill="#fff" d="M8 7.89h24v24H8z" /></clipPath>
  </defs>
</svg>`,aw=ke`<svg fill="none" viewBox="0 0 40 40">
  <g clip-path="url(#a)">
    <g clip-path="url(#b)">
      <circle cx="20" cy="19.89" r="20" fill="#fff" fill-opacity=".05" />
      <g clip-path="url(#c)">
        <path
          fill="#4285F4"
          d="M20 17.7v4.65h6.46a5.53 5.53 0 0 1-2.41 3.61l3.9 3.02c2.26-2.09 3.57-5.17 3.57-8.82 0-.85-.08-1.67-.22-2.46H20Z"
        />
        <path
          fill="#34A853"
          d="m13.27 22.17-.87.67-3.11 2.42A12 12 0 0 0 20 31.9c3.24 0 5.96-1.07 7.94-2.9l-3.9-3.03A7.15 7.15 0 0 1 20 27.12a7.16 7.16 0 0 1-6.72-4.94v-.01Z"
        />
        <path
          fill="#FBBC05"
          d="M9.29 14.5a11.85 11.85 0 0 0 0 10.76l3.99-3.1a7.19 7.19 0 0 1 0-4.55l-4-3.1Z"
        />
        <path
          fill="#EA4335"
          d="M20 12.66c1.77 0 3.34.61 4.6 1.8l3.43-3.44A11.51 11.51 0 0 0 20 7.89c-4.7 0-8.74 2.69-10.71 6.62l3.99 3.1A7.16 7.16 0 0 1 20 12.66Z"
        />
      </g>
    </g>
  </g>
  <defs>
    <clipPath id="a"><rect width="40" height="40" fill="#fff" rx="20" /></clipPath>
    <clipPath id="b"><path fill="#fff" d="M0 0h40v40H0z" /></clipPath>
    <clipPath id="c"><path fill="#fff" d="M8 7.89h24v24H8z" /></clipPath>
  </defs>
</svg>`,UR=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    d="M8.51 5.66a.83.83 0 0 0-.57-.2.83.83 0 0 0-.52.28.8.8 0 0 0-.25.52 1 1 0 0 1-2 0c0-.75.34-1.43.81-1.91a2.75 2.75 0 0 1 4.78 1.92c0 1.24-.8 1.86-1.25 2.2l-.04.03c-.47.36-.5.43-.5.65a1 1 0 1 1-2 0c0-1.25.8-1.86 1.24-2.2l.04-.04c.47-.36.5-.43.5-.65 0-.3-.1-.49-.24-.6ZM9.12 11.87a1.13 1.13 0 1 1-2.25 0 1.13 1.13 0 0 1 2.25 0Z"
  />
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6a6 6 0 1 0 0 12A6 6 0 0 0 8 2Z"
    clip-rule="evenodd"
  />
</svg>`,wo=ke`<svg fill="none" viewBox="0 0 14 15">
  <path
    fill="currentColor"
    d="M6 10.49a1 1 0 1 0 2 0v-2a1 1 0 0 0-2 0v2ZM7 4.49a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z"
  />
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M7 14.99a7 7 0 1 0 0-14 7 7 0 0 0 0 14Zm5-7a5 5 0 1 1-10 0 5 5 0 0 1 10 0Z"
    clip-rule="evenodd"
  />
</svg>`,Kn=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M4.83 1.34h6.34c.68 0 1.26 0 1.73.04.5.05.97.15 1.42.4.52.3.95.72 1.24 1.24.26.45.35.92.4 1.42.04.47.04 1.05.04 1.73v3.71c0 .69 0 1.26-.04 1.74-.05.5-.14.97-.4 1.41-.3.52-.72.95-1.24 1.25-.45.25-.92.35-1.42.4-.47.03-1.05.03-1.73.03H4.83c-.68 0-1.26 0-1.73-.04-.5-.04-.97-.14-1.42-.4-.52-.29-.95-.72-1.24-1.24a3.39 3.39 0 0 1-.4-1.41A20.9 20.9 0 0 1 0 9.88v-3.7c0-.7 0-1.27.04-1.74.05-.5.14-.97.4-1.42.3-.52.72-.95 1.24-1.24.45-.25.92-.35 1.42-.4.47-.04 1.05-.04 1.73-.04ZM3.28 3.38c-.36.03-.51.08-.6.14-.21.11-.39.29-.5.5a.8.8 0 0 0-.08.19l5.16 3.44c.45.3 1.03.3 1.48 0L13.9 4.2a.79.79 0 0 0-.08-.2c-.11-.2-.29-.38-.5-.5-.09-.05-.24-.1-.6-.13-.37-.04-.86-.04-1.6-.04H4.88c-.73 0-1.22 0-1.6.04ZM14 6.54 9.85 9.31a3.33 3.33 0 0 1-3.7 0L2 6.54v3.3c0 .74 0 1.22.03 1.6.04.36.1.5.15.6.11.2.29.38.5.5.09.05.24.1.6.14.37.03.86.03 1.6.03h6.25c.73 0 1.22 0 1.6-.03.35-.03.5-.09.6-.14.2-.12.38-.3.5-.5.05-.1.1-.24.14-.6.03-.38.03-.86.03-1.6v-3.3Z"
    clip-rule="evenodd"
  />
</svg>`,$R=ke`<svg fill="none" viewBox="0 0 20 20">
  <path fill="currentColor" d="M10.81 5.81a2 2 0 1 1-4 0 2 2 0 0 1 4 0Z" />
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M3 4.75A4.75 4.75 0 0 1 7.75 0h4.5A4.75 4.75 0 0 1 17 4.75v10.5A4.75 4.75 0 0 1 12.25 20h-4.5A4.75 4.75 0 0 1 3 15.25V4.75ZM7.75 2A2.75 2.75 0 0 0 5 4.75v10.5A2.75 2.75 0 0 0 7.75 18h4.5A2.75 2.75 0 0 0 15 15.25V4.75A2.75 2.75 0 0 0 12.25 2h-4.5Z"
    clip-rule="evenodd"
  />
</svg>`,jR=ke`<svg fill="none" viewBox="0 0 22 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M16.32 13.62a3.14 3.14 0 1 1-.99 1.72l-1.6-.93a3.83 3.83 0 0 1-3.71 1 3.66 3.66 0 0 1-1.74-1l-1.6.94a3.14 3.14 0 1 1-1-1.73l1.6-.94a3.7 3.7 0 0 1 0-2 3.81 3.81 0 0 1 1.8-2.33c.29-.17.6-.3.92-.38V6.1a3.14 3.14 0 1 1 2 0l-.01.02v1.85H12a3.82 3.82 0 0 1 2.33 1.8 3.7 3.7 0 0 1 .39 2.91l1.6.93ZM2.6 16.54a1.14 1.14 0 0 0 1.98-1.14 1.14 1.14 0 0 0-1.98 1.14ZM11 2.01a1.14 1.14 0 1 0 0 2.28 1.14 1.14 0 0 0 0-2.28Zm1.68 10.45c.08-.19.14-.38.16-.58v-.05l.02-.13v-.13a1.92 1.92 0 0 0-.24-.8l-.11-.15a1.89 1.89 0 0 0-.74-.6 1.86 1.86 0 0 0-.77-.17h-.19a1.97 1.97 0 0 0-.89.34 1.98 1.98 0 0 0-.61.74 1.99 1.99 0 0 0-.16.9v.05a1.87 1.87 0 0 0 .24.74l.1.15c.12.16.26.3.42.42l.16.1.13.07.04.02a1.84 1.84 0 0 0 .76.17h.17a2 2 0 0 0 .91-.35 1.78 1.78 0 0 0 .52-.58l.03-.05a.84.84 0 0 0 .05-.11Zm5.15 4.5a1.14 1.14 0 0 0 1.14-1.97 1.13 1.13 0 0 0-1.55.41c-.32.55-.13 1.25.41 1.56Z"
    clip-rule="evenodd"
  />
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M4.63 9.43a1.5 1.5 0 1 0 1.5-2.6 1.5 1.5 0 0 0-1.5 2.6Zm.32-1.55a.5.5 0 0 1 .68-.19.5.5 0 0 1 .18.68.5.5 0 0 1-.68.19.5.5 0 0 1-.18-.68ZM17.94 8.88a1.5 1.5 0 1 1-2.6-1.5 1.5 1.5 0 1 1 2.6 1.5ZM16.9 7.69a.5.5 0 0 0-.68.19.5.5 0 0 0 .18.68.5.5 0 0 0 .68-.19.5.5 0 0 0-.18-.68ZM9.75 17.75a1.5 1.5 0 1 1 2.6 1.5 1.5 1.5 0 1 1-2.6-1.5Zm1.05 1.18a.5.5 0 0 0 .68-.18.5.5 0 0 0-.18-.68.5.5 0 0 0-.68.18.5.5 0 0 0 .18.68Z"
    clip-rule="evenodd"
  />
</svg>`,WR=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M9.13 1h1.71c1.46 0 2.63 0 3.56.1.97.1 1.8.33 2.53.85a5 5 0 0 1 1.1 1.11c.53.73.75 1.56.86 2.53.1.93.1 2.1.1 3.55v1.72c0 1.45 0 2.62-.1 3.55-.1.97-.33 1.8-.86 2.53a5 5 0 0 1-1.1 1.1c-.73.53-1.56.75-2.53.86-.93.1-2.1.1-3.55.1H9.13c-1.45 0-2.62 0-3.56-.1-.96-.1-1.8-.33-2.52-.85a5 5 0 0 1-1.1-1.11 5.05 5.05 0 0 1-.86-2.53c-.1-.93-.1-2.1-.1-3.55V9.14c0-1.45 0-2.62.1-3.55.1-.97.33-1.8.85-2.53a5 5 0 0 1 1.1-1.1 5.05 5.05 0 0 1 2.53-.86C6.51 1 7.67 1 9.13 1ZM5.79 3.09a3.1 3.1 0 0 0-1.57.48 3 3 0 0 0-.66.67c-.24.32-.4.77-.48 1.56-.1.82-.1 1.88-.1 3.4v1.6c0 1.15 0 2.04.05 2.76l.41-.42c.5-.5.93-.92 1.32-1.24.41-.33.86-.6 1.43-.7a3 3 0 0 1 .94 0c.35.06.66.2.95.37a17.11 17.11 0 0 0 .8.45c.1-.08.2-.2.41-.4l.04-.03a27 27 0 0 1 1.95-1.84 4.03 4.03 0 0 1 1.91-.94 4 4 0 0 1 1.25 0c.73.11 1.33.46 1.91.94l.64.55V9.2c0-1.52 0-2.58-.1-3.4a3.1 3.1 0 0 0-.48-1.56 3 3 0 0 0-.66-.67 3.1 3.1 0 0 0-1.56-.48C13.37 3 12.3 3 10.79 3h-1.6c-1.52 0-2.59 0-3.4.09Zm11.18 10-.04-.05a26.24 26.24 0 0 0-1.83-1.74c-.45-.36-.73-.48-.97-.52a2 2 0 0 0-.63 0c-.24.04-.51.16-.97.52-.46.38-1.01.93-1.83 1.74l-.02.02c-.17.18-.34.34-.49.47a2.04 2.04 0 0 1-1.08.5 1.97 1.97 0 0 1-1.25-.27l-.79-.46-.02-.02a.65.65 0 0 0-.24-.1 1 1 0 0 0-.31 0c-.08.02-.21.06-.49.28-.3.24-.65.59-1.2 1.14l-.56.56-.65.66a3 3 0 0 0 .62.6c.33.24.77.4 1.57.49.81.09 1.88.09 3.4.09h1.6c1.52 0 2.58 0 3.4-.09a3.1 3.1 0 0 0 1.56-.48 3 3 0 0 0 .66-.67c.24-.32.4-.77.49-1.56l.07-1.12Zm-8.02-1.03ZM4.99 7a2 2 0 1 1 4 0 2 2 0 0 1-4 0Z"
    clip-rule="evenodd"
  />
</svg>`,Pt=ke`<svg fill="none" viewBox="0 0 16 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M8 0a1 1 0 0 1 1 1v5.38a1 1 0 0 1-2 0V1a1 1 0 0 1 1-1ZM5.26 2.6a1 1 0 0 1-.28 1.39 5.46 5.46 0 1 0 6.04 0 1 1 0 1 1 1.1-1.67 7.46 7.46 0 1 1-8.25 0 1 1 0 0 1 1.4.28Z"
    clip-rule="evenodd"
  />
</svg>`,qR=ke` <svg
  width="36"
  height="36"
  fill="none"
>
  <path
    d="M0 8a8 8 0 0 1 8-8h20a8 8 0 0 1 8 8v20a8 8 0 0 1-8 8H8a8 8 0 0 1-8-8V8Z"
    fill="#fff"
    fill-opacity=".05"
  />
  <path
    d="m18.262 17.513-8.944 9.49v.01a2.417 2.417 0 0 0 3.56 1.452l.026-.017 10.061-5.803-4.703-5.132Z"
    fill="#EA4335"
  />
  <path
    d="m27.307 15.9-.008-.008-4.342-2.52-4.896 4.36 4.913 4.912 4.325-2.494a2.42 2.42 0 0 0 .008-4.25Z"
    fill="#FBBC04"
  />
  <path
    d="M9.318 8.997c-.05.202-.084.403-.084.622V26.39c0 .218.025.42.084.621l9.246-9.247-9.246-8.768Z"
    fill="#4285F4"
  />
  <path
    d="m18.33 18 4.627-4.628-10.053-5.828a2.427 2.427 0 0 0-3.586 1.444L18.329 18Z"
    fill="#34A853"
  />
  <path
    d="M8 .5h20A7.5 7.5 0 0 1 35.5 8v20a7.5 7.5 0 0 1-7.5 7.5H8A7.5 7.5 0 0 1 .5 28V8A7.5 7.5 0 0 1 8 .5Z"
    stroke="#fff"
    stroke-opacity=".05"
  />
</svg>`,oi=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
  />
</svg>`,$u=ke`<svg fill="none" viewBox="0 0 14 16">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M3.94 1.04a1 1 0 0 1 .7 1.23l-.48 1.68a5.85 5.85 0 0 1 8.53 4.32 5.86 5.86 0 0 1-11.4 2.56 1 1 0 0 1 1.9-.57 3.86 3.86 0 1 0 1.83-4.5l1.87.53a1 1 0 0 1-.55 1.92l-4.1-1.15a1 1 0 0 1-.69-1.23l1.16-4.1a1 1 0 0 1 1.23-.7Z"
    clip-rule="evenodd"
  />
</svg>`,ow=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    d="M9.36 4.21a5.14 5.14 0 1 0 0 10.29 5.14 5.14 0 0 0 0-10.29ZM1.64 9.36a7.71 7.71 0 1 1 14 4.47l2.52 2.5a1.29 1.29 0 1 1-1.82 1.83l-2.51-2.51A7.71 7.71 0 0 1 1.65 9.36Z"
    clip-rule="evenodd"
  />
</svg>`,z7=ke`<svg fill="none" viewBox="0 0 21 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    clip-rule="evenodd"
  />
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width="21"
    height="20"
    viewBox="0 0 21 20"
    fill="none"
  ></svg></svg
>`,cw=ke`<svg fill="none" viewBox="0 0 20 20">
  <path
    fill="currentColor"
    fill-rule="evenodd"
    clip-rule="evenodd"
  />
</svg>`,ju=ke`<svg width="10" height="10" viewBox="0 0 10 10">
