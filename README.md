# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

---

API Framework for Salesforce

Salesforce의 API의 기반을 잡아 유지보수를 용이하게 하고, 개발 속도 향상 및 비용을 낮추기 위해 개발되었습니다.

## Package Install URL - 1.1 
: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t2w0000093nfv

## 주의

- Nebula Logger Package를 사용하기 때문에, 먼저 등록 후 진행해주셔야 합니다.
- Nebula Logger Git URL : https://github.com/jongpie/NebulaLogger

## 특징

1. API Gateway Class를 Inbound, Outbound를 나누고, 서비스 개발 영역도 구분, 파라미터를 구분하여 여러 환경에 대응 가능한 활용성 증대 추구.
2. API Service 정보를 Custom Metadata(API_Routing__mdt)로 관리, API Management를 통해 코드 수정 없이 경로, 사용여부 등 변경 가능하게 하여 개발 및 운영의 용이성 up.
3. Nebula Logger를 활용하여 Log를 API Management에서 서비스 별로 확인 가능.
4. Callout Test Tab을 통해 쉽게 API 테스트 가능.

<table>
    <thead>
        <tr>
            <th>API_Routing__mdt</th>
            <th>Field API Name</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td></td>
            <td>InterfaceID__c</td>
            <td>API Service 관리 Id(Key)</td>
        </tr>
        <tr>
            <td></td>
            <td>URI__c</td>
            <td>API Service Endpoint URI</td>
        </tr>
        <tr>
            <td></td>
            <td>HttpMethod__c</td>
            <td>HTTP Method Type</td>
        </tr>
        <tr>
            <td></td>
            <td>isActive__c</td>
            <td>API Service 사용 여부</td>
        </tr>
        <tr>
            <td></td>
            <td>Description__c</td>
            <td>비고</td>
        </tr>
        <tr>
            <td></td>
            <td>ServiceClass__c</td>
            <td>Service Class Name</td>
        </tr>
        <tr>
            <td></td>
            <td>ExampleParam__c</td>
            <td>호출 예제 파라미터</td>
        </tr>
        <tr>
            <td></td>
            <td>LegacySystem__c</td>
            <td>Outbound 대상 시스템 명</td>
        </tr>
        <tr>
            <td></td>
            <td>timeout__c</td>
            <td>Read timeout 설정 값</td>
        </tr>
        <tr>
            <td></td>
            <td>Direction__c</td>
            <td>송수신 여부</td>
        </tr>
        <tr>
            <td></td>
            <td>mappingDefinition__c</td>
            <td>Record 매핑 정보</td>
        </tr>
    </tbody>
</table>