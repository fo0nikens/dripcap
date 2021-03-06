<drip-session-list>
  <ul>
    <li tabindex="0" each={ sess, i in sessions } class={ session: true, selected: i == activeIndex } onclick={ setIndex }>
      <i class={ fa: true, fa-circle-o-notch: true, fa-spin: status.get(sess).capturing }></i>
      { sess.name || sess.interface } <span>{ status.get(sess).packets }</span>
      <ul show={ i == activeIndex }>
        <li tabindex="0" onclick={ pause } show={ sess.interface && status.get(sess).capturing }><i class="fa fa-pause"></i> Pause</li>
        <li tabindex="0" onclick={ start } show={ sess.interface && !status.get(sess).capturing }><i class="fa fa-play"></i> Start</li>
        <li tabindex="0" onclick={ remove }><i class="fa fa-trash"></i> Remove</li>
      </ul>
    </li>
    <li class="button" tabindex="0" onclick={ newSession }><i class="fa fa-plus"></i> New Session</li>
  </ul>
  <ul>
    <li class="button" tabindex="0" onclick={ showPreferences }><i class="fa fa-cogs"></i> Preferences</li>
  </ul>
  <style type="text/less">
    :scope > ul {
      padding: 0;
      margin: 0;
      -webkit-user-select: none;

      > li {
        list-style: none;
        padding: 10px 10px;
        margin: 3px 0;
        cursor: pointer;
      }

      > li.selected {
        background-color: var(--color-selection-background);
      }

      > li.session {
        border-left: 5px solid transparent;

        &:hover {
          border-left: 5px solid var(--color-selection-background);
        }

        > span {
          border-radius: 15px;
          background-color: var(--color-variables);
          padding: 0 8px;
          float: right;
        }

        > ul {
          list-style: none;
          margin-top: 5px;
          padding: 5px 10px;

          > li {
            padding: 5px;
            &:hover {
              text-decoration: underline;
            }
          }
        }
      }

      > li.button {
        border-left: 5px solid transparent;
        color: var(--color-default-background);
        background-color: var(--color-functions);
        &:hover {
          border-left: 5px solid var(--color-selection-background);
        }
      }
    }
  </style>

  <script>
    const _ = require('underscore');
    const {PubSub} = require('dripcap');
    this.sessions = [];
    this.status = new WeakMap();
    this.activeIndex = -1;

    start(e) {
      let sess = this.sessions[e.item.i];
      if (sess) {
        sess.start();
      }
      e.preventUpdate = true;
      e.stopPropagation();
    }

    pause(e) {
      let sess = this.sessions[e.item.i];
      if (sess) {
        sess.stop();
      }
      e.preventUpdate = true;
      e.stopPropagation();
    }

    remove(e) {
      let sess = this.sessions[e.item.i];
      if (sess) {
        PubSub.emit('core:session-removed', sess);
      }
      e.preventUpdate = true;
      e.stopPropagation();
    }

    newSession(e) {
      PubSub.emit('core:new-live-session');
      e.preventUpdate = true;
      e.stopPropagation();
    }

    showPreferences(e) {
      PubSub.emit('core:show-preferences');
      e.preventUpdate = true;
      e.stopPropagation();
    }

    setIndex(e) {
      this._setIndex(e.item.i);
    }

    _setIndex(index) {
      if (this.activeIndex != index) {
        this.activeIndex = index;
        let sess = this.sessions[index];
        PubSub.pub('core:session-selected', {session: sess, status: this.status.get(sess)});
      }
    }

    PubSub.on('core:session-added', (sess) => {
      this.sessions.push(sess);
      this.status.set(sess, {capturing: false, packets: 0});
      sess.on('status', _.throttle((stat) => {
        this.status.set(sess, stat);
        this.update();
      }, 500));
      if (this.activeIndex < 0) this._setIndex(0);
      this.update();
    });

    PubSub.on('core:session-removed', (sess) => {
      let index = this.sessions.indexOf(sess);
      if (index >= 0) {
        let sess = this.sessions[index];
        sess.stop();
        sess.removeAllListeners();
        this.sessions.splice(index, 1);
        if (this.activeIndex >= this.sessions.length)
          this._setIndex(this.sessions.length - 1);
        this.update();
      }
    });

  </script>
</drip-session-list>
