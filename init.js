#!/bin/env node

const awsKey = process.argv[2];
const awsSecret = process.argv[3];
const snsTopic = process.argv[4];
const snsRegion = process.argv[5];

// Github User 名
const userName = process.argv[6];
// Github User アクセストークン
const accessToken = process.argv[7];
// Github 対象レポジトリ名リスト
const repositoryNameList = process.argv.slice(8);

//------------------------------------//

const hostname = 'api.github.com';
const auth = `${userName}:${accessToken}`;
const userAgent = 'nodejs';

const https = require('https');

console.log('Add Amazon SNS setting...');


const getSnsHookID = (repositoryName) => {
  return new Promise((resolve, reject) => {
    req = https.request({
      method: 'GET',
      hostname: hostname,
      path: `/repos/${userName}/${repositoryName}/hooks`,
      auth: auth,
      headers: {
        'User-Agent': userAgent
      }
    }, (res) => {
      let body = '';
      res.on('data', (c) => {
        body += c;
      });
      res.on('end', () => {
        resolve(JSON.parse(body).find((e) => {
          return e.name === 'amazonsns';
        }));
      });
      res.on('error', (e) => {
        return reject(e);
      });
    });

    req.on('error', (e) => {
      return reject(e);
    });
    req.end();
  });
}

const craetePRHook = (repositoryName) => {
  const postBody = JSON.stringify({
    name: 'amazonsns',
    config: {
      'aws_key': awsKey,
      'aws_secret': awsSecret,
      'sns_topic': snsTopic,
      'sns_region': snsRegion
    },
    events: [
      'pull_request'
    ],
    active: true
  });
  return new Promise((resolve, reject) => {
    req = https.request({
      method: 'POST',
      hostname: hostname,
      path: `/repos/${userName}/${repositoryName}/hooks`,
      auth: auth,
      headers: {
        'User-Agent': userAgent,
        'Content-Type': 'application/json',
        'Content-Length': postBody.length
      }
    }, (res) => {
      let body = '';
      res.on('data', (c) => {
        body += c;
      })
      res.on('end', () => {
        return resolve(JSON.parse(body));
      })
      res.on('error', (e) => {
        return reject(e);
      })
    });
    req.write(postBody);
    req.on('error', (e) => {
      return reject(e);
    });
    req.end();
  });
}

const editPRHook = (repositoryName, id) => {
  const postBody = JSON.stringify({
    name: 'amazonsns',
    config: {
      'aws_key': awsKey,
      'aws_secret': awsSecret,
      'sns_topic': snsTopic,
      'sns_region': snsRegion
    },
    events: [
      'pull_request'
    ],
    active: true
  });
  return new Promise((resolve, reject) => {
    req = https.request({
      method: 'PATCH',
      hostname: hostname,
      path: `/repos/${userName}/${repositoryName}/hooks/${id}`,
      auth: auth,
      headers: {
        'User-Agent': userAgent,
        'Content-Type': 'application/json',
        'Content-Length': postBody.length
      }
    }, (res) => {
      let body = '';
      res.on('data', (c) => {
        body += c;
      })
      res.on('end', () => {
        return resolve(JSON.parse(body));
      })
      res.on('error', (e) => {
        return reject(e);
      })
    });
    req.write(postBody);
    req.on('error', (e) => {
      return reject(e);
    });
    req.end();
  });
}

repositoryNameList.forEach((repositoryName) => {
  getSnsHookID(repositoryName)
    .then((target) => {
      if (target) {
        return editPRHook(repositoryName, target.id);
      }
      return craetePRHook(repositoryName);
    })
    .then((data) => {
      console.log(`${repositoryName} Done.`);
    })
    .catch((cause) => {
      console.error(cause);
      console.log(`${repositoryName} Failed.`);
    });
});