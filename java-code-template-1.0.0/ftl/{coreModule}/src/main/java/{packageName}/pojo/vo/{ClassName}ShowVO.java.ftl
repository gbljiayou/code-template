<#include "/abstracted/common.ftl">
<#include "/abstracted/mtmCascadeExtsForShow.ftl">
<#--定义主体代码-->
<#assign code>
<@call this.addImport("io.swagger.annotations.ApiModel")/>
<@call this.addImport("io.swagger.annotations.ApiModelProperty")/>
<@call this.addImport("${this.commonPackage}.pojo.vo.AbstractVO")/>
<@call this.addStaticImport("${this.packageName}.pojo.example.${this.classNameUpper}Example.*")/>
<@call this.printClassCom("【${this.title}】详情展示对象")/>
@ApiModel(description = "【${this.title}】详情展示对象")
public class ${this.classNameUpper}ShowVO extends AbstractVO {

<#--当前实体详情展示字段-->
<#list this.showFields as id,field>
    <#--import字段类型-->
    <@call this.addFieldTypeImport(field)/>
    <#--字段名转下划线大写-->
    <#assign jfieldNameSnakeCase = CommonTemplateFunction.camelCaseToSnakeCase(field.jfieldName,true)>
    <#if field.dicType??>
        <@call this.addConstImport(field.dicType)/>
    </#if>
    @ApiModelProperty(notes = N_${jfieldNameSnakeCase},example = E_${jfieldNameSnakeCase}<#if field.dicType??>, allowableValues = ${JavaTemplateFunction.fetchClassName(field.dicType)}.VALUES_STR</#if>)
    <#if field.jfieldType==JFieldType.DATE.getJavaType()>
        <@call this.addImport("com.fasterxml.jackson.annotation.JsonFormat")/>
        <@call this.addImport("${this.commonPackage}.constant.JsonFieldConst")/>
    @JsonFormat(pattern=JsonFieldConst.DEFAULT_DATETIME_FORMAT,timezone="GMT+8")
    </#if>
    private ${field.jfieldType} ${field.jfieldName};

</#list>
<#--外键级联扩展，详情展示字段-->
<#list this.fkFields as id,field>
    <#list field.cascadeShowExts! as cascadeExt>
        <#assign cascadeField=cascadeExt.cascadeField>
        <#--import字段类型-->
        <@call this.addFieldTypeImport(cascadeField)/>
        <#assign exampleClass="">
        <#if cascadeField.dicType??>
            <@call this.addConstImport(cascadeField.dicType)/>
        </#if>
        <#if field.foreignEntity!=this.metaEntity>
            <@call this.addImport("${this.packageName}.pojo.example.${field.foreignEntity.className?capFirst}Example")/>
            <#assign exampleClass="${field.foreignEntity.className?capFirst}Example.">
        </#if>
        <#--字段名转下划线大写-->
        <#assign jfieldNameSnakeCase = CommonTemplateFunction.camelCaseToSnakeCase(cascadeField.jfieldName,true)>
    @ApiModelProperty(notes = ${exampleClass}N_${jfieldNameSnakeCase},example = ${exampleClass}E_${jfieldNameSnakeCase}<#if cascadeField.dicType??>, allowableValues = ${JavaTemplateFunction.fetchClassName(cascadeField.dicType)}.VALUES_STR</#if>)
        <#if cascadeField.jfieldType==JFieldType.DATE.getJavaType()>
            <@call this.addImport("com.fasterxml.jackson.annotation.JsonFormat")/>
            <@call this.addImport("${this.commonPackage}.constant.JsonFieldConst")/>
    @JsonFormat(pattern=JsonFieldConst.DEFAULT_DATETIME_FORMAT,timezone="GMT+8")
        </#if>
    private ${cascadeField.jfieldType} ${cascadeExt.alias};

        </#list>
</#list>
<#--多对多随实体一起维护并且未设置级联扩展时，需要返回对方的id列表-->
<#list this.holds! as otherEntity,mtm>
    <#if mtm.getEntityFeature(this.entityId).withinEntity
        && !mtmCascadeEntitiesForShow?seqContains(otherEntity)>
        <@call this.addImport("java.util.List")/>
        <#assign othercName=otherEntity.className?uncapFirst>
    @ApiModelProperty(notes = "【${otherEntity.title}】主键列表")
    private List<${otherEntity.pkField.jfieldType}> ${othercName}List;

    </#if>
</#list>
<#--多对多级联扩展详情展示-->
<#list mtmCascadeEntitiesForShow as otherEntity>
    <@call this.addImport("java.util.List")/>
    <#assign otherCName=otherEntity.className/>
    <#assign othercName=otherEntity.className?uncapFirst>
    @ApiModelProperty(notes = "【${otherEntity.title}】列表")
    private List<${otherCName}VO> ${othercName}List;

</#list>

<#--当前实体详情展示字段：getter-setter方法-->
<#list this.showFields as id,field>
    <@call JavaTemplateFunction.printGetterSetter(field)/>
</#list>
<#--外键级联扩展，详情展示字段：getter-setter方法-->
<#list this.fkFields as id,field>
    <#list field.cascadeShowExts! as cascadeExt>
        <@call JavaTemplateFunction.printGetterSetter(cascadeExt.alias,cascadeExt.cascadeField.jfieldType)/>
    </#list>
</#list>
<#--多对多随实体一起维护并且未设置级联扩展时，需要返回对方的id列表-->
<#list this.holds! as otherEntity,mtm>
    <#if mtm.getEntityFeature(this.entityId).withinEntity
        && !mtmCascadeEntitiesForShow?seqContains(otherEntity)>
        <@call JavaTemplateFunction.printGetterSetterList("${othercName}List",otherEntity.pkField.jfieldType,false)/>
    </#if>
</#list>
<#--多对多级联扩展详情展示：getter-setter方法-->
<#list mtmCascadeEntitiesForShow as otherEntity>
    <#assign otherCName=otherEntity.className/>
    <#assign othercName=otherEntity.className?uncapFirst>
    <@call JavaTemplateFunction.printGetterSetterList(othercName,"${otherCName}VO")/>
</#list>

<#--多对多级联扩展详情展示【静态内部类】-->
<#list mtmCascadeEntitiesForShow as otherEntity>
    <#assign mtmCascadeExts = groupMtmCascadeExtsForShow[otherEntity?index]>
    <#assign otherCName=otherEntity.className?capFirst>
    <#assign exampleClass="${otherEntity.className?capFirst}Example">
    <@call this.addImport("${this.packageName}.pojo.example.${exampleClass}")/>
    public static class ${otherCName}VO extends AbstractVO {

    <#--主键字段-->
    <#assign pkField=otherEntity.pkField>
    <#--字段名转下划线大写-->
    <#assign pkFieldNameSnakeCase = CommonTemplateFunction.camelCaseToSnakeCase(pkField.jfieldName,true)>
        @ApiModelProperty(notes = ${exampleClass}.N_${pkFieldNameSnakeCase},example = ${exampleClass}.E_${pkFieldNameSnakeCase})
        private ${pkField.jfieldType} ${pkField.jfieldName};

    <#--多对多级联扩展，列表展示字段-->
    <#list mtmCascadeExts as mtmCascadeExt>
        <#assign field=mtmCascadeExt.cascadeField>
        <#--import字段类型-->
        <@call this.addFieldTypeImport(field)/>
        <#--字段名转下划线大写-->
        <#assign jfieldNameSnakeCase = CommonTemplateFunction.camelCaseToSnakeCase(field.jfieldName,true)>
        <#if field.dicType??>
            <@call this.addConstImport(field.dicType)/>
        </#if>
        @ApiModelProperty(notes = ${exampleClass}.N_${jfieldNameSnakeCase},example = ${exampleClass}.E_${jfieldNameSnakeCase}<#if field.dicType??>, allowableValues = ${JavaTemplateFunction.fetchClassName(field.dicType)}.VALUES_STR</#if>)
        <#if field.jfieldType==JFieldType.DATE.getJavaType()>
            <@call this.addImport("com.fasterxml.jackson.annotation.JsonFormat")/>
            <@call this.addImport("${this.commonPackage}.constant.JsonFieldConst")/>
            @JsonFormat(pattern=JsonFieldConst.DEFAULT_DATETIME_FORMAT,timezone="GMT+8")
        </#if>
        private ${field.jfieldType} ${field.jfieldName};

    </#list>

    <#--主键字段：getter-setter方法-->
    <@call JavaTemplateFunction.printGetterSetter(pkField,2)/>
    <#--多对多级联扩展，列表展示字段：getter-setter方法-->
    <#list mtmCascadeExts as mtmCascadeExt>
        <#assign field=mtmCascadeExt.cascadeField>
        <@call JavaTemplateFunction.printGetterSetter(field,2)/>
    </#list>

    }
</#list>

}
</#assign>
<#--开始渲染代码-->
package ${this.packageName}.pojo.vo;

<@call this.printImport()/>

${code}
