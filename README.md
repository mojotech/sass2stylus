Sass2Stylus
----------
#[Use it live](http://sass2stylus.com)

[![Build Status](https://travis-ci.org/mojotech/sass2stylus.svg)](https://travis-ci.org/mojotech/sass2stylus)

### API Usage

#### With cURL
```sh
curl -F file=@/your/local/file.scss http://sass2stylus.com/api > new_file.styl
```
#### With Ruby
```ruby
RestClient.post('http://sass2stylus.com/api', file: File.open('local_file.scss'))
```
---

##### Sass2Stylus is curated by loving hands at...
<a href="http://mojotech.com"><img width="140px" src="https://mojotech.github.io/sass2stylus/img/mojotech-logo.svg" title="MojoTech's Hiring"></a> <sup>(psst, [we're hiring](http://www.mojotech.com/jobs))</sup>
