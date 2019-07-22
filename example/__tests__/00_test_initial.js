import helper from 'tipsi-appium-helper'
import test from './utils/tape'

const { screenshot } = helper

test('Test if we can take a screenshot', async (t) => {

  await screenshot()
  t.pass('Screenshot taken')

})
