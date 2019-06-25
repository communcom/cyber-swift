# API's
[Documentation](https://github.com/GolosChain/api-documentation)


## Facade-Service
[Documentation](https://github.com/GolosChain/facade-service)


### API 'auth.authorize'
* 17.04.2019:
 - add `displayName` in ResponseAPI

### API 'auth.generateSecret'

### API 'content.getProfile'

### API 'content.getFeed'
* 18.06.2019:
- change `downCount` type: `UInt64?` -> `Int64?` 

### API 'content.getPost'

### API 'content.getComments' by user
* 17.04.2019:
- add `embeds` in ResponseAPI

* 18.06.2019:
- change `downCount` type: `UInt64?` -> `Int64?` 

### API 'content.getComments' by post
* 18.04.2019:
- change `refBlockNum` type: `String` -> `UInt64`

### API 'push.notifyOn'
* 25.06.2019:
- create API
- 

### API 'push.historyFresh'

### API 'options.get'
* 23.04.2019:
- create API

### API basic 'options.set'
* 24.04.2019:
- create API

### API push 'options.set'
* 25.04.2019:
- create API

### API notify 'options.set'
* 26.04.2019:
- create API

### API notify 'markAsRead'
* 22.05.2019:
- create API

### API 'meta.recordPostView'
* 22.05.2019:
- create API

### API 'favorites.get'
* 29.05.2019:
- create API

### API 'favorites.add'
* 29.05.2019:
- create API

### API 'favorites.remove'
* 29.05.2019:
- create API


## Registration-Service
[Documentation](https://github.com/GolosChain/registration-service/tree/develop)


### API 'registration.getState'

### API 'registration.firstStep'

### API 'registration.verify'

### API 'registration.setUsername'

### API 'registration.resendSmsCode'
* 19.04.2019:
- create API

### API 'registration.resendSmsCode'


## Contracts
[Documentation](https://github.com/GolosChain/golos.contracts)



## golos.social.abi
[Documentation](https://github.com/GolosChain/golos.contracts/blob/develop/golos.social/golos.social.abi)

### API 'social.block', 'social.unblock'

### API 'social.pin', 'social.unpin'
* 25.04.2019:
- add 'responseResult' & 'responseError'

### API 'social.updatemeta'
* 25.04.2019:
- create contract
- change image type: String -> UIImage

### API 'social.deletemeta'


## golos.vesting.abi
[Documentation](https://github.com/GolosChain/golos.contracts/blob/master/golos.vesting/golos.vesting.abi)



## golos.publication.abi
[Documentation](https://github.com/GolosChain/golos.contracts/blob/master/golos.publication/golos.publication.abi)


### Actions 'upvote', 'downvote', 'unvote'
* 18.06.2019:
- change `weight` type: `Int16` -> `UInt16`

### Action 'createmssg'

### Action 'updatemssg'

### Action 'deletemssg'

### Action 'reblog' - in progress



## golos.config.abi
[Documentation](https://github.com/GolosChain/golos.contracts/blob/master/golos.config/abi/golos.config.abi)



## golos.ctrl.abi
[Documentation](https://github.com/GolosChain/golos.contracts/blob/master/golos.ctrl/abi/golos.ctrl.abi)


### Action 'regwitness'

### Action 'votewitness'

### Action 'unvotewitn'

### Action 'unregwitness'



## Note
[узнать поднят ли 46 б/ч](http://116.203.39.126:7777/bc_status)
[рестарт newtesterbot in Slack](http://116.203.39.126:7777/slack_bot_restart)
