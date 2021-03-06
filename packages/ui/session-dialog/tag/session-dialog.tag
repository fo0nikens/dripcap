<session-dialog>
  <div>
    <h2>New session</h2>
    <p>
      <select ref="interface">
        <option each={ interfaceList } if={ link===1 } value={ encodeURI(id) }>{ name }</option>
      </select>
    </p>
    <p>
      <input type="text" ref="filter" placeholder="filter (BPF)">
    </p>
    <p>
      <label>
        <input type="checkbox" ref="promisc">
        Promiscuous mode
      </label>
    </p>
    <p>
      <input type="button" name="start" value="Start" onclick={ start }>
    </p>
  </div>

  <style>
    :scope > div {
      padding: 10px 20px;
    }
  </style>

  <script>
    const $ = require('jquery');
    const { Session, Layout, Profile, PubSub } = require('dripcap');

    this.interfaceList = Session.devices;

    start() {
      let ifs = decodeURI($(this.refs.interface).val());
      let filter = $(this.refs.filter).val();
      let promisc = $(this.refs.promisc).prop('checked');
      let snaplen = Profile.getConfig('snaplen');

      Session.create({
        ifs: ifs,
        filter: filter,
        promiscuous: promisc,
        snaplen: snaplen
      }).then(sess => {
        PubSub.emit('core:session-added', sess);
        sess.start();
        sess.on('log', log => {
          PubSub.pub('core:log', {
            level: log.level,
            message: log.message,
            timestamp: new Date(),
            data: log.data
          });
        });
      });

      Layout.container('drip-modal').close();
    }
  </script>
</session-dialog>
