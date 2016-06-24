/* global describe, it */
var path = require('path')
var assert = require('assert')
var mongoose = require('mongoose')
var ShortId = require('mongoose-shortid-nodeps')
var mockgoose = require('mockgoose')
mockgoose(mongoose)
var proxyquire = require('proxyquire')
function Global (m) {
  m[ '@noCallThru' ] = true
  m[ '@global' ] = true
  return m
}
var yaktor = {
  log: {
    stdout: true,
    level: 'info',
    filename: ''
  }
}
var logger = proxyquire('yaktor/lib/logger', { '../index' : yaktor })
var proxy = {
  yaktor: yaktor,
  'yaktor/logger': logger
}
require(path.resolve('src-gen', 'modelAll'))
describe('Agent', function () {
  describe('Test.Test', function () {
    it('should be loaded', function () {
      var test = proxyquire(path.resolve('conversations', 'js', 'Test'), proxy)
      assert.ok(test.agents['Test.Test'])
      assert.ok(test.agents['Test.Test'].states)
      assert.ok(test.agents['Test.Test'].states.working)
      assert.ok(test.agents['Test.Test'].states.working.transitions)
      assert.ok(test.agents['Test.Test'].states.working.transitions.finished)
      assert.ok(test.agents['Test.Test'].states.working.transitions.finished.to)
      assert.equal(test.agents['Test.Test'].states.working.transitions.finished.to, test.agents['Test.Test'].states.done)
      assert.ok(test.agents['Test.TestDepend'])
    })
  })
  describe('UserUnitTest.Test.Test', function () {
    it('should be loaded', function () {
      var Test = proxyquire(path.resolve('conversations', 'js', 'Test'), proxy)
      var UserUnitTest = proxyquire(path.resolve('conversations', 'js', 'UserUnitTest'), proxy)
      assert.ok(Test.agents['Test.Test'])
      assert.ok(UserUnitTest.agents['Test.Test'])
      assert.equal(UserUnitTest.agents['Test.Test'], Test.agents['Test.Test'])
    })
  })
})
