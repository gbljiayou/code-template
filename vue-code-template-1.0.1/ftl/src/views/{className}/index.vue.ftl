<#include "/abstracted/common.ftl">
<#include "/abstracted/table.ftl">
<#include "/abstracted/mtmCascadeExtsForQuery.ftl">
<#include "/abstracted/mtmCascadeExtsForList.ftl">
<#if !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <div class="app-container">
    <div class="filter-container">
<#-- 把渲染搜索字段的逻辑抽象出来 -->
<#macro displayQueryField field alias>
    <#local name = alias?hasContent?string(alias,field.jfieldName)/>
    <#-- 首先考虑外键的情况 -->
    <#if field.foreignKey>
        <@justCall importOtherEntitys.add(field.foreignEntity)/>
        <#assign foreignClassName = field.foreignEntity.className?uncapFirst>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 filterable clearable<#if QueryType.isIn(field.queryType)> multiple</#if>>
        <el-option v-for="item in options.${foreignClassName}"
                   :key="item.key"
                   :label="item.value"
                   :value="item.key">
        </el-option>
      </el-select>
    <#-- 其次考虑枚举的情况 -->
    <#elseIf field.dicType??>
        <#assign const = findConst(field.dicType)>
        <@justCall importEnums.add(const)/>
        <#assign constName = const.constName?uncapFirst>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 filterable clearable<#if QueryType.isIn(field.queryType)> multiple</#if>>
        <el-option v-for="item in enums.${constName}"
                   :key="item.value"
                   :label="item.label"
                   :value="item.value">
        </el-option>
      </el-select>
    <#-- 非Between查询条件 -->
    <#elseIf !QueryType.isBetween(field.queryType)>
        <#if field.editType == EditType.NUMBER.getValue()>
      <el-input-number v-model="query.${name}" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                       style="width:200px;" class="filter-item"
                       controls-position="right"></el-input-number>
        <#elseIf field.editType == EditType.DATE.getValue()>
      <el-date-picker v-model="query.${name}" type="date"
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"></el-date-picker>
        <#elseIf field.editType == EditType.DATETIME.getValue()>
      <el-date-picker v-model="query.${name}" type="datetime"
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"></el-date-picker>
        <#elseIf field.jfieldType == JFieldType.BOOLEAN.javaType>
      <el-select v-model="query.${name}" class="filter-item"
                 style="width:200px;" placeholder="${field.fieldDesc}"
                 clearable>
        <el-option label="是" :value="true"></el-option>
        <el-option label="否" :value="false"></el-option>
      </el-select>
        <#else>
      <el-input v-model="query.${name}" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                clearable style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
        </#if>
    <#-- 最后考虑Between查询条件 -->
    <#else>
        <#if field.jfieldType == JFieldType.DATE.javaType>
      <el-date-picker v-model="query.${name}Start"
            <#if field.editType == EditType.DATE.getValue()>
                      type="date"
            <#else>
                      type="datetime"
            </#if>
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"></el-date-picker>
      <el-date-picker v-model="query.${name}End"
            <#if field.editType == EditType.DATE.getValue()>
                      type="date"
            <#else>
                      type="datetime"
            </#if>
                      style="width:200px;" class="filter-item"
                      value-format="yyyy-MM-dd HH:mm:ss"
                      placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"></el-date-picker>
        <#elseIf field.editType == EditType.NUMBER.getValue()>
      <el-input-number v-model="query.${name}Start" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"
                       style="width:200px;" class="filter-item"
                       controls-position="right"></el-input-number>
      <el-input-number v-model="query.${name}End" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                       style="width:200px;" class="filter-item"
                       controls-position="right"></el-input-number>
        <#else>
      <el-input v-model="query.${name}Start" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,true)}"
                style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
      <el-input v-model="query.${name}End" placeholder="${field.fieldDesc}${getRangeQueryTipSuffix(field,false)}"
                style="width: 200px;" class="filter-item"
                @keyup.enter.native="handleQuery"/>
        </#if>
    </#if>
</#macro>
<#assign hasQueryField = false>
<#--渲染查询输入框-->
<#list this.queryFields as id,field>
    <#assign hasQueryField = true>
    <@displayQueryField field ""/>
</#list>
<#--开始渲染【外键级联扩展】字段 -->
<#list this.fkFields as id,field>
    <#list field.cascadeQueryExts! as cascadeExt>
        <#assign hasQueryField = true>
        <@displayQueryField cascadeExt.cascadeField cascadeExt.alias/>
    </#list>
</#list>
<#--开始渲染【多对多级联扩展】字段-->
<#list mtmCascadeExtsForQuery as mtmCascadeExt>
    <#assign hasQueryField = true>
    <@displayQueryField mtmCascadeExt.cascadeField mtmCascadeExt.alias/>
</#list>
    <el-button-group>
<#if hasQueryField>
      <el-button class="filter-item" icon="el-icon-search" type="primary"
                 @click="handleQuery">
        搜索
      </el-button>
</#if>
<#if this.entityFeature.save>
      <el-button class="filter-item" style="margin-left: 10px;" type="success"
                 icon="el-icon-edit" @click="handleCreate">
        新建
      </el-button>
</#if>
<#if this.entityFeature.deleteBatch>
      <el-button class="filter-item" style="margin-left: 10px;" type="danger"
                 icon="el-icon-delete" @click="handleDeleteBatch">
        删除
      </el-button>
</#if>
    </el-button-group>
    </div>

    <el-table v-loading="listLoading" :data="list" height="520"
<#if tableSelect>
              @selection-change="selectionChange"
</#if>
<#if tableSort>
              @sort-change="sortChange"
</#if>
              border stripe style="width: 100%;">
<#if tableSelect>
      <el-table-column type="selection" width="50" />
</#if>
<#-- 把渲染字段的逻辑抽象出来 -->
<#macro displayTableColumn field alias>
    <#-- 不渲染外键字段 -->
    <#if field.foreignKey><#return></#if>
    <#local name = alias?hasContent?string(alias,field.jfieldName)/>
      <el-table-column label="${field.fieldDesc}"
                       prop="${name}"
    <#if !(alias?hasContent) && field.listSort>
                       sortable="custom"
    </#if>
                       align="center"<#if field.columnWidth?? && field.columnWidth &gt; 0> width="${field.columnWidth}"</#if>>
        <template slot-scope="{row}">
    <#-- 枚举字段特殊处理 -->
    <#if field.dicType??>
        <#assign const = findConst(field.dicType)>
        <@justCall importEnums.add(const)/>
        <#assign constName = const.constName?uncapFirst>
          <span>{{ row.${name} | findEnumLabel(enums.${constName}) }}</span>
    <#-- 普通字段直接展示 -->
    <#else>
          <span>{{ row.${name} }}</span>
    </#if>
        </template>
      </el-table-column>
</#macro>
<#-- 列表字段 -->
<#list this.listFields as id,field>
      <@displayTableColumn field ""/>
</#list>
<#-- 外键级联扩展字段 -->
<#list this.fkFields as id,field>
    <#list field.cascadeListExts! as cascadeExt>
        <@displayTableColumn cascadeExt.cascadeField cascadeExt.alias/>
    </#list>
</#list>
<#--多对多级联扩展列表展示-->
<#list mtmCascadeEntitiesForList as otherEntity>
    <#assign otherPkField = otherEntity.pkField>
    <#assign mtmCascadeExts = groupMtmCascadeExtsForList[otherEntity?index]>
    <#--级联扩展列表字段中，如果有标题字段，则使用标题字段展示，否则直接展示主键字段-->
    <#if hasTitleField(otherEntity,mtmCascadeExts)>
        <#assign displayField = otherEntity.titleField>
    <#else>
        <#assign displayField = otherPkField>
    </#if>
    <#assign othercName=otherEntity.className?uncapFirst>
      <el-table-column label="${otherEntity.title}" align="center">
        <template slot-scope="{row}">
          <span v-for="item in row.${othercName}List"
                :key="item.${otherPkField.jfieldName}"
                class="table-inner-mtm">
            {{ item.${displayField.jfieldName} }}
          </span>
        </template>
      </el-table-column>
</#list>
<#if tableOperate>
      <el-table-column label="操作" align="center" width="100px" fixed="right">
        <template slot-scope="{row}">
            <el-dropdown size="small" trigger="click" @command="handleCommand" style="margin-left:10px;">
                    <span class="el-dropdown-link button-font">操作
                    <i class="el-icon-arrow-down el-icon--right"></i></span>
                <el-dropdown-menu slot="dropdown">
                    <#if this.entityFeature.show>
                        <el-dropdown-item :command="{method:'handleShow',arg:row}" >查看</el-dropdown-item>
                    </#if>
                    <#if this.entityFeature.update>
                        <el-dropdown-item :command="{method:'handleUpdate',arg:row}" >编辑</el-dropdown-item>
                    </#if>
                    <#if this.entityFeature.delete>
                    <el-dropdown-item :command="{method:'handleDeleteSingle',arg:row}" >删除</el-dropdown-item>
                    </#if>
                    <el-dropdown-item>
                         <#list this.holds! as otherEntity,mtm>
                             <#assign otherCName=otherEntity.className?capFirst>
                             <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
                             <#if entityFeature.addRemove>
                                 <el-dropdown-item :command="{method:'handle${otherCName}AddRemove',arg:row}" >配置${otherEntity.title}</el-dropdown-item>
                             <#elseIf entityFeature.set>
                                 <el-dropdown-item :command="{method:'handle${otherCName}Setting',arg:row}" >配置${otherEntity.title}</el-dropdown-item>
                             </#if>
                         </#list>
                    </el-dropdown-item>
                </el-dropdown-menu>
            </el-dropdown>
        </template>
      </el-table-column>
</#if>
    </el-table>
<#if this.pageSign>
    <pagination v-show="total>0" :total="total" :page.sync="query.page"
                :limit.sync="query.limit" @pagination="doQueryList"/>
</#if>
<#if this.entityFeature.save>
    <!-- 新建表单 -->
    <${this.className}-add ref="${this.className}Add" @created="doQueryList({<#if this.pageSign> page: 1 </#if>})"/>
</#if>
<#if this.entityFeature.update>
    <!-- 编辑表单 -->
    <${this.className}-edit ref="${this.className}Edit" @updated="doQueryList({})"/>
</#if>
<#if this.entityFeature.show>
    <!-- 查看表单 -->
    <${this.className}-show ref="${this.className}Show"/>
</#if>
<#list this.holds! as otherEntity,mtm>
    <#assign othercName=otherEntity.className?uncapFirst>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if entityFeature.addRemove>
    <!-- 添加移除${otherEntity.title} -->
    <${othercName}-add-remove ref="${othercName}AddRemove" @updated="doQueryList({})"/>
    <#elseIf entityFeature.set>
    <!-- 设置${otherEntity.title} -->
    <${othercName}-setting ref="${othercName}Setting" @updated="doQueryList({})"/>
    </#if>
</#list>
  </div>
</template>

<script>
<#if this.entityFeature.save>
import ${this.className}Add from './add'
</#if>
<#if this.entityFeature.update>
import ${this.className}Edit from './edit'
</#if>
<#if this.entityFeature.show>
import ${this.className}Show from './show'
</#if>
<#list this.holds! as otherEntity,mtm>
    <#assign othercName=otherEntity.className?uncapFirst>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if entityFeature.addRemove>
import ${othercName}AddRemove from './${othercName}AddRemove'
    <#elseIf entityFeature.set>
import ${othercName}Setting from './${othercName}Setting'
    </#if>
</#list>
import ${this.className}Api from '@/api/${this.className}'
<#if !importOtherEntitys.isEmpty()>
    <#list importOtherEntitys as foreignEntity>
        <#assign foreignClassName = foreignEntity.className?uncapFirst>
import ${foreignClassName}Api from '@/api/${foreignClassName}'
    </#list>
</#if>
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>
<#if this.pageSign>
import Pagination from '@/components/Pagination'
</#if>

export default {
  name: '${this.classNameUpper}Table',
  components: {
<@removeLastComma>
    <#if this.pageSign>
    Pagination,
    </#if>
    <#if this.entityFeature.save>
    ${this.className}Add,
    </#if>
    <#if this.entityFeature.update>
    ${this.className}Edit,
    </#if>
    <#if this.entityFeature.show>
    ${this.className}Show,
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign othercName=otherEntity.className?uncapFirst>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove>
    ${othercName}AddRemove,
        <#elseIf entityFeature.set>
    ${othercName}Setting,
        </#if>
    </#list>
</@removeLastComma>
  },
<#if !importEnums.isEmpty()>
  filters: {
    findEnumLabel: enums.findEnumLabel
  },
</#if>
  data() {
    return {
<#if !importEnums.isEmpty()>
      enums: {
    <@removeLastComma>
        <#list importEnums as const>
        ${const.constName?uncapFirst}: enums.get${const.constName}(),
        </#list>
    </@removeLastComma>
      },
</#if>
<#if !importOtherEntitys.isEmpty()>
      options: {
    <@removeLastComma>
        <#list importOtherEntitys as foreignEntity>
        ${foreignEntity.className?uncapFirst}: [],
        </#list>
    </@removeLastComma>
      },
</#if>
<@removeLastComma>
      list: [],
      total: 0,
      listLoading: true,
      query: {
    <@removeLastComma>
        <#if this.pageSign>
        page: 1,
        limit: 10,
        </#if>
        <#list this.queryFields as id,field>
            <#if QueryType.isIn(field.queryType)>
        ${field.jfieldName}: [],
            <#elseIf !QueryType.isBetween(field.queryType)>
        ${field.jfieldName}: ${getFieldEmptyValue(field)},
            <#else>
        ${field.jfieldName}Start: ${getFieldEmptyValue(field)},
        ${field.jfieldName}End: ${getFieldEmptyValue(field)},
            </#if>
        </#list>
        <#list this.listSortFields as id,field>
        ${field.jfieldName}SortSign: 0,
        </#list>
    </@removeLastComma>
      },
    <#if tableSelect>
      selectItems: [],
    </#if>
</@removeLastComma>
    }
  },
  created() {
    this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
<#if !importOtherEntitys.isEmpty()>
    <@removeLastComma>
        <#list importOtherEntitys as foreignEntity>
            <#assign foreignClassName = foreignEntity.className?uncapFirst>
    ${foreignClassName}Api.findOptions().then(data => { this.options.${foreignClassName} = data })
        </#list>
    </@removeLastComma>
</#if>
  },
  methods: {
<@removeLastComma>
    /**
     *
     */
    handleCommand: function (command) {
      this[command.method](command.arg)
    },
    <#if tableSelect>
    /**
     * 选择框变化
     */
    selectionChange(val) {
      this.selectItems = val
    },
    </#if>
    <#if tableSort>
    /**
     * 触发后端排序
     */
    sortChange({ prop, order }) {
      const sortKeyMap = {
        <@removeLastComma>
            <#list this.listSortFields as id,field>
        '${field.jfieldName}': '${field.jfieldName}SortSign',
            </#list>
        </@removeLastComma>
      }
      for (var k in sortKeyMap) {
        const sortKey = sortKeyMap[k]
        if (k !== prop) {
          this.query[sortKey] = null
        } else {
          if (order === 'ascending') {
            this.query[sortKey] = 1
          } else {
            this.query[sortKey] = -1
          }
        }
      }
      this.doQueryList({})
    },
    </#if>
    /**
     * 触发搜索操作
     */
    handleQuery() {
      this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
    },
    /**
     * 执行列表查询
     */
    doQueryList(<#if this.pageSign>{ page, limit }</#if>) {
    <#if this.pageSign>
      if (page) {
        this.query.page = page
      }
      if (limit) {
        this.query.limit = limit
      }
    </#if>
      this.listLoading = true
      return ${this.className}Api.fetchList(this.query)
        .then(data => {
    <#if this.pageSign>
          this.list = data.list
          this.total = data.total
    <#else>
          this.list = data
    </#if>
        })
        .finally(() => {
          this.listLoading = false
        })
    },
    <#if this.entityFeature.delete>
    /**
     * 删除单条记录
     */
    handleDeleteSingle(row) {
      return this.$common.confirm('是否确认删除')
        .then(() => ${this.className}Api.deleteById(row.${this.id}))
        .then(() => {
          this.$common.showMsg('success', '删除成功')
          return this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
        })
    },
    </#if>
    <#if this.entityFeature.deleteBatch>
    /**
     * 批量删除记录
     */
    handleDeleteBatch() {
      if (this.selectItems.length <= 0) {
        this.$common.showMsg('warning', '请选择${this.title}')
        return
      }
      return this.$common.confirm('是否确认删除')
        .then(() => ${this.className}Api.deleteBatch(this.selectItems.map(row => row.${this.id})))
        .then(() => {
          this.$common.showMsg('success', '删除成功')
          return this.doQueryList(<#if this.pageSign>{ page: 1 }</#if>)
        })
    },
    </#if>
    <#if this.entityFeature.save>
    /**
     * 打开新建表单
     */
    handleCreate() {
      this.$refs.${this.className}Add.handleCreate()
    },
    </#if>
    <#if this.entityFeature.show>
    /**
     * 打开查看表单
     */
    handleShow(row) {
      this.$refs.${this.className}Show.handleShow(row.${this.id})
    },
    </#if>
    <#if this.entityFeature.update>
    /**
     * 打开编辑表单
     */
    handleUpdate(row) {
      this.$refs.${this.className}Edit.handleUpdate(row.${this.id})
    },
    </#if>
    <#list this.holds! as otherEntity,mtm>
        <#assign otherCName=otherEntity.className?capFirst>
        <#assign othercName=otherEntity.className?uncapFirst>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.addRemove>
    /**
     * 打开添加移除${otherEntity.title}表单
     */
    handle${otherCName}AddRemove(row) {
      this.$refs.${othercName}AddRemove.handleShow(row.${this.id})
    },
        <#elseIf entityFeature.set>
    /**
     * 打开设置${otherEntity.title}表单
     */
    handle${otherCName}Setting(row) {
      this.$refs.${othercName}Setting.handleShow(row.${this.id})
    },
        </#if>
    </#list>
</@removeLastComma>
  }
}
</script>
