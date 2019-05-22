# API's
[Documentation](https://github.com/GolosChain/api-documentation)


## Facade-Service
[Documentation](https://github.com/GolosChain/facade-service)


### API 'auth.authorize'
* 17.04.2019:
 - add 'displayName' in ResponseAPI

### API 'auth.generateSecret'

### API 'content.getProfile'

### API 'content.getFeed'

### API 'content.getPost'

### API 'content.getComments' by user
* 17.04.2019:
- add 'embeds' in ResponseAPI

### API 'content.getComments' by post
* 18.04.2019:
- change 'refBlockNum' type: String -> UInt64

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
[Documentation](https://github.com/GolosChain/golos.contracts/blob/master/golos.social/golos.social.abi)

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
