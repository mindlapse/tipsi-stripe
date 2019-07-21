import helper from 'tipsi-appium-helper'
import test from './utils/tape'
import openTestSuite from './common/openTestSuite'

const { driver, select, platform, idFromAccessId, idFromResourceId } = helper

const timeout = 60000

test('Test if user can use Card Form', async (t) => {
  const cardFormButton = idFromAccessId('cardFormButton')
  const numberInputId = select({
    ios: idFromAccessId('card number'),
    android: idFromResourceId('com.example:id/cc_card'),
  })

  const inputExpData = select({
    ios: idFromAccessId('expiration date'),
    android: idFromResourceId('com.example:id/cc_exp'),
  })

  const inputCVC = select({
    ios: idFromAccessId('CVC'),
    android: idFromResourceId('com.example:id/cc_ccv'),
  })

  const doneButtonId = select({
    ios: idFromAccessId('Done'),
    android: idFromResourceId('android:id/button1'),
  })
  const nextButtonId = idFromAccessId('Next')
  const tokenId = idFromAccessId('cardFormToken')

  await openTestSuite('Card Form')
  console.log(await driver.source())

  await driver.waitForVisible(cardFormButton, timeout)
  t.pass('User should see `Enter you card and pay` button')

  await driver.click(cardFormButton)
  t.pass('User should be able to tap on `Enter you card and pay` button')

  await driver.waitForVisible(numberInputId, timeout)
  await driver.click(numberInputId)
  await driver.keys('4242424242424242')

  await driver.waitForVisible(inputExpData, timeout)
  await driver.keys('12/34')

  await driver.waitForVisible(inputCVC, timeout)
  await driver.keys('123')

  t.pass('User should be able write card data')

  // Iterate over billing address fields (iOS only)
  // Verifies that all fields are filled
  if (platform('ios')) {
    for (const index of new Array(7)) { // eslint-disable-line no-unused-vars
      await driver.waitForVisible(nextButtonId, timeout)
      await driver.click(nextButtonId)
    }
  }

  await driver.waitForEnabled(doneButtonId, timeout)
  await driver.click(doneButtonId)
  t.pass('User should be able to tap on `Done` button')

  // Sometimes on Travis we have a problem with the network connection,
  // it is related to problems with current container or slow android emulator
  if (platform('android')) {
    try {
      await driver.waitForVisible(tokenId, 180000)
    } catch (error) {
      try {
        t.pass('Token does not exist, try click done button again')
        await driver.waitForEnabled(doneButtonId, 50000)
        await driver.click(doneButtonId)
      } catch (error) { // eslint-disable-line no-shadow, no-empty
        t.pass('Done button does not exist, wait for token')
      }
    }
  }

  await driver.waitForVisible(tokenId, 180000)
  t.pass('User should see token')
})
