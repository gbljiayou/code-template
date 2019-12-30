<#include "/abstracted/common.ftl">
<#list this.metaEntities as metaEntity>
DROP TABLE IF EXISTS `${metaEntity.tableName}`;

CREATE TABLE `${metaEntity.tableName}` (
    <#list metaEntity.fields as fieldId,field>
        <#assign comma_holder><#if metaEntity?hasNext || metaEntity.pkField?? || (metaEntity.indexes?? && (metaEntity.indexes?size > 0))>,</#if></#assign>
    `${field.fieldName}` ${field.fieldType}${SqlTemplateFunction.getLengthDisplay(field)}${SqlTemplateFunction.getAutoIncrementDisplay(field)}${SqlTemplateFunction.getNotNullDisplay(field)}${SqlTemplateFunction.getDefaultDisplay(field)}${SqlTemplateFunction.getCommentDisplay(field.fetchComment(),true)}${comma_holder}
    </#list>
    <#if metaEntity.pkField??>
    PRIMARY KEY (`${metaEntity.pkField.fieldName}`)<#if metaEntity.indexes?? && (metaEntity.indexes?size > 0)>,</#if>
    </#if>
    <#list metaEntity.indexes! as index>
    <#if index.unique>UNIQUE </#if>KEY `${index.indexName}` (<#list index.fields as field>`${field.fieldName}`<#if field?hasNext >,</#if></#list>) USING BTREE<#if index?hasNext>,</#if>
    </#list>
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4${SqlTemplateFunction.getCommentDisplay(metaEntity.desc,false)};

</#list>
<#list this.mtms! as mtm>
    <#assign field1=mtm.refer1.pkField>
    <#assign field2=mtm.refer2.pkField>
DROP TABLE IF EXISTS `${mtm.tableName}`;

CREATE TABLE `${mtm.tableName}` (
    <#if mtm.needId>
    `id` <#if mtm.bigId>bigint(20)<#else>int(11)</#if> AUTO_INCREMENT COMMENT '主键',
    </#if>
    `${mtm.fkAliasForSql1}` ${field1.fieldType}${SqlTemplateFunction.getLengthDisplay(field1)} NOT NULL${SqlTemplateFunction.getCommentDisplay(field1.fetchComment(),true)},
    `${mtm.fkAliasForSql2}` ${field2.fieldType}${SqlTemplateFunction.getLengthDisplay(field2)} NOT NULL${SqlTemplateFunction.getCommentDisplay(field2.fetchComment(),true)},
    `created_time` datetime DEFAULT NULL COMMENT '创建时间',
    <#if mtm.needId>
    PRIMARY KEY (`id`),
    </#if>
    KEY `IDX_${mtm.tableName?upperCase}_1` (`${mtm.fkAliasForSql1}`),
    KEY `IDX_${mtm.tableName?upperCase}_2` (`${mtm.fkAliasForSql2}`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4${SqlTemplateFunction.getCommentDisplay(mtm.desc,false)};

</#list>
