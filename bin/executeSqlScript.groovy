#!/usr/bin/env groovy
 
import groovy.sql.Sql
import java.text.*
 
def executeSqlScript(args) {
  def cli = new CliBuilder(usage: 'executeSqlScript.groovy -[lsdupfh]')
  // Create the list of options.
  cli.with {
    l longOpt: 'listenport', args: 1, argName: 'port',     'DB2 server listening port'
    s longOpt: 'server',     args: 1, argName: 'server',   'DB2 server hostname'
    d longOpt: 'database',   args: 1, argName: 'database', 'DB2 database'
    u longOpt: 'username',   args: 1, argName: 'username', 'DB2 user\'s username'
    p longOpt: 'password',   args: 1, argName: 'password', 'DB2 user\'s password'
    f longOpt: 'file',       args: 1, argName: 'file',     'File with SQL script'
    h longOpt: 'help',       'Show usage information'
  }
 
  def options = cli.parse(args)
  if (!options) {
    return
  }
  // Show usage text when -h or --help option is used.
  if (options.h) {
    cli.usage()
    // Will output:
    // usage: executeSqlScript.groovy -[lsdupfh]
    //  -s,--server <hostname>     DB2 server hostname
    //  -l,--listenport <port>     DB2 server listening port
    //  -d,--database <database>   DB2 database
    //  -u,--username <username>   DB2 user\'s username
    //  -p,--password <password>   DB2 user\'s password
    //  -f,--file <file>           File with SQL script
    //  -h,--help                  Show usage information
    return
  }
 
  sql = Sql.newInstance( 'jdbc:db2://' + options.s + ':' + options.l + '/' + options.d, option.u, options.p, 'com.ibm.db2.jcc.DB2Driver' )
 
  new File(options.f).eachLine{ line ->
    sql.execute(line)
  }
}
 
println executeSqlScript(args)
