export default class IPv6 {
  activate() {
    dripcap.session.on('created', (session) => {
      session.addDecoder(`${__dirname}/ipv6`)
    })
  }

  deactivate() {}
}