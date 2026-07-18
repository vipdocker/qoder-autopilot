function render(data) {
  show(data.userName);    // camelize provides it -> OK
  show(data.createdAt);   // camelize provides it -> OK
  show(data.emailAddr);   // camelize DROPPED email_addr -> undefined at runtime (seeded defect R3)
}
